from __future__ import annotations

import io
from typing import Optional

from fastapi import APIRouter, File, Form, UploadFile, HTTPException
from PIL import Image
import pytesseract
from indic_transliteration import sanscript
from indic_transliteration.sanscript import SchemeMap, SCHEMES, transliterate

from schemas import TransliterateTextIn, TransliterateOut


router = APIRouter(prefix="/transliterate", tags=["transliteration"])


def normalize_script_name(name: Optional[str]) -> Optional[str]:
    if not name:
        return None
    key = name.strip().lower()
    # Map common aliases
    alias = {
        "devanagari": sanscript.DEVANAGARI,
        "hindi": sanscript.DEVANAGARI,
        "iast": sanscript.IAST,
        "itrans": sanscript.ITRANS,
        "telugu": sanscript.TELUGU,
        "kannada": sanscript.KANNADA,
        "tamil": sanscript.TAMIL,
        "malayalam": sanscript.MALAYALAM,
        "gujarati": sanscript.GUJARATI,
        "gurmukhi": sanscript.GURMUKHI,
        "bengali": sanscript.BENGALI,
        "oriya": sanscript.ORIYA,
    }
    return alias.get(key, key)


@router.post("/", response_model=TransliterateOut)
def transliterate_text(payload: TransliterateTextIn):
    source_script = normalize_script_name(payload.source_script) or sanscript.DEVANAGARI
    target_script = normalize_script_name(payload.target_script) or sanscript.IAST

    if source_script not in SCHEMES or target_script not in SCHEMES:
        raise HTTPException(status_code=400, detail="Unsupported script specified")

    result = transliterate(payload.source_text, source_script, target_script)
    return TransliterateOut(
        source_text=payload.source_text,
        source_script=source_script,
        target_script=target_script,
        transliterated_text=result,
    )


@router.post("/image", response_model=TransliterateOut)
async def transliterate_image(
    file: UploadFile = File(...),
    source_script: Optional[str] = Form(None),
    target_script: str = Form(...),
):
    try:
        content = await file.read()
        image = Image.open(io.BytesIO(content))
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid image file")

    # OCR with pytesseract. Users must have appropriate language data installed (e.g., hin).
    # Default to English if not specified; allow specifying custom language via filename hint later.
    ocr_lang = "eng+hin"  # Try both for MVP
    try:
        extracted_text = pytesseract.image_to_string(image, lang=ocr_lang)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OCR failed: {str(e)}")

    src_script = normalize_script_name(source_script) or sanscript.DEVANAGARI
    tgt_script = normalize_script_name(target_script) or sanscript.IAST
    if src_script not in SCHEMES or tgt_script not in SCHEMES:
        raise HTTPException(status_code=400, detail="Unsupported script specified")

    result = transliterate(extracted_text, src_script, tgt_script)
    return TransliterateOut(
        source_text=extracted_text,
        source_script=src_script,
        target_script=tgt_script,
        transliterated_text=result,
    )
