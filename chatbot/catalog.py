import asyncio
import logging
import os
import time

import httpx

logger = logging.getLogger(__name__)

RUTSEG_API_URL = os.getenv("RUTSEG_API_URL", "http://localhost:3000")
REFRESH_SECONDS = int(os.getenv("CATALOG_REFRESH_SECONDS", "3600"))  # 1 hora por defecto

# Fallback estático — se usa mientras no haya completado el primer refresh exitoso,
# o si el backend no responde. Uchi nunca se queda sin catálogo, en el peor caso
# responde con uno desactualizado en vez de no saber nada.
_FALLBACK_CATALOG_TEXT = (
    "Catálogo actual: 6 cursos publicados — Fundamentos de Ciberseguridad (principiante), "
    "Seguridad en Redes y Criptografía (intermedio), Pentesting Avanzado y Escalada de Privilegios "
    "(avanzado), OWASP A01 - Control de Acceso Roto (intermedio), OWASP A05 - Inyección (intermedio) "
    "y OWASP A07 - Fallos de Autenticación (intermedio). Si te preguntan por un curso o lab "
    "específico que no reconoces por nombre, dilo con honestidad en vez de inventar el contenido."
)
_FALLBACK_ROUTES_TEXT = (
    "- /courses/fundamentos-ciberseguridad — Fundamentos de Ciberseguridad\n"
    "- /courses/redes-criptografia — Seguridad en Redes y Criptografía\n"
    "- /courses/pentesting-avanzado — Pentesting Avanzado y Escalada de Privilegios\n"
    "- /courses/owasp-a01-control-acceso — OWASP A01: Control de Acceso Roto\n"
    "- /courses/owasp-a05-inyeccion — OWASP A05: Inyección\n"
    "- /courses/owasp-a07-fallos-autenticacion — OWASP A07: Fallos de Autenticación"
)

_catalog_text = _FALLBACK_CATALOG_TEXT
_routes_text = _FALLBACK_ROUTES_TEXT
_last_refreshed: float | None = None
_last_course_count: int | None = None


def get_catalog_text() -> str:
    return _catalog_text


def get_course_routes_text() -> str:
    return _routes_text


def get_refresh_status() -> dict:
    return {"lastRefreshedAt": _last_refreshed, "courseCount": _last_course_count}


async def refresh_catalog() -> None:
    """Trae los cursos publicados desde el backend (GET /api/courses, público) y
    reconstruye el texto de catálogo y de rutas que usa el system prompt. Si falla,
    conserva el último catálogo bueno conocido — nunca lo deja vacío."""
    global _catalog_text, _routes_text, _last_refreshed, _last_course_count

    async with httpx.AsyncClient(timeout=10.0) as client:
        res = await client.get(f"{RUTSEG_API_URL}/api/courses")
        res.raise_for_status()
        courses = res.json()

    if not courses:
        _catalog_text = (
            "Actualmente no hay cursos publicados en RutSeg. Si te preguntan por un curso, "
            "dilo con honestidad en vez de inventar contenido."
        )
        _routes_text = "(sin cursos publicados por ahora)"
    else:
        items = "; ".join(f"{c['title']} ({c['difficulty']})" for c in courses)
        n = len(courses)
        _catalog_text = (
            f"Catálogo actual: {n} curso{'s' if n != 1 else ''} publicado{'s' if n != 1 else ''} "
            f"— {items}. Si te preguntan por un curso o lab específico que no reconoces por "
            "nombre, dilo con honestidad en vez de inventar el contenido."
        )
        _routes_text = "\n".join(f"- /courses/{c['slug']} — {c['title']}" for c in courses)

    _last_refreshed = time.time()
    _last_course_count = len(courses)
    logger.info(f"[Catalog] Catálogo actualizado: {len(courses)} curso(s) publicado(s)")


async def start_refresh_loop() -> None:
    """Refresca el catálogo al arrancar y luego cada REFRESH_SECONDS, indefinidamente.
    Cualquier error (backend caído, timeout, respuesta inesperada) se loggea y se
    ignora — el loop nunca muere, solo conserva el catálogo anterior hasta el
    siguiente intento."""
    while True:
        try:
            await refresh_catalog()
        except Exception as e:
            logger.warning(f"[Catalog] No se pudo refrescar el catálogo ({e}); se conserva el anterior.")
        await asyncio.sleep(REFRESH_SECONDS)
