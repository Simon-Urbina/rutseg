from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address
import asyncio
import json
import logging
import time

from config import client, MODEL
from prompts import build_system_prompt
from retriever import retriever
from catalog import start_refresh_loop, get_refresh_status

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def get_client_ip(request: Request) -> str:
    # Railway proxea este servicio igual que el backend — la IP del socket
    # crudo (request.client.host, lo que usa get_remote_address por defecto)
    # sería siempre la del proxy de Railway, no la del cliente real.
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return get_remote_address(request)


# Límite generoso a propósito: pensado para que una demo en vivo frente a un
# grupo grande (ej. una charla/congreso) donde muchas personas comparten la
# misma red — y por lo tanto la misma IP pública tras el NAT del router — no
# se vea bloqueada entre sí. Sigue acotando un abuso automatizado real (un
# script pegándole al endpoint sin parar agotaría 300 peticiones en minutos).
limiter = Limiter(key_func=get_client_ip)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # El catálogo de cursos se refresca en background (ver catalog.py) para que Uchi
    # no dependa de editar knowledge.json/prompts.py a mano cada vez que se publica
    # un curso nuevo. El primer fetch ocurre aquí mismo al arrancar; si falla, el
    # servidor sigue arrancando igual con el catálogo de respaldo.
    task = asyncio.create_task(start_refresh_loop())
    yield
    task.cancel()


app = FastAPI(title="Uchi – RutSeg AI Assistant", lifespan=lifespan)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["POST", "OPTIONS"],
    allow_headers=["*"],
)

MAX_HISTORY = 20


class Message(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    messages: list[Message]
    context: dict = {}


async def stream_response(messages: list[dict]):
    t0 = time.time()
    logger.info(f"[Uchi] Solicitando a {MODEL}...")
    stream = await client.chat.completions.create(
        model=MODEL,
        messages=messages,
        temperature=0.7,
        stream=True,
    )
    first = True
    async for chunk in stream:
        delta = chunk.choices[0].delta.content
        if delta:
            if first:
                logger.info(f"[Uchi] Primer token en {time.time() - t0:.1f}s")
                first = False
            yield f"data: {json.dumps({'chunk': delta})}\n\n"
    logger.info(f"[Uchi] Stream completo en {time.time() - t0:.1f}s total")
    yield "data: [DONE]\n\n"


@app.post("/chat/stream")
@limiter.limit("300/10minutes")
async def chat_stream(request: Request, req: ChatRequest):
    history = req.messages[-MAX_HISTORY:]

    # Recuperar FAQs relevantes usando la última pregunta del usuario
    last_user_msg = next((m.content for m in reversed(history) if m.role == "user"), "")
    relevant_faqs = retriever.retrieve(last_user_msg) if last_user_msg else []
    if relevant_faqs:
        logger.info(f"[RAG] {len(relevant_faqs)} FAQ(s) recuperadas para: '{last_user_msg[:50]}'")

    system_prompt = build_system_prompt(req.context, relevant_faqs)
    messages = [{"role": "system", "content": system_prompt}]
    messages += [{"role": m.role, "content": m.content} for m in history]

    return StreamingResponse(
        stream_response(messages),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        },
    )


@app.get("/health")
async def health():
    return {"status": "ok", "model": MODEL, "catalog": get_refresh_status()}
