from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
import json
import logging
import time

from config import client, MODEL
from prompts import build_system_prompt
from retriever import retriever

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Uchi – RutSeg AI Assistant")

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
async def chat_stream(req: ChatRequest):
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
    return {"status": "ok", "model": MODEL}
