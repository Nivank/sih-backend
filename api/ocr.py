from fastapi import APIRouter, UploadFile, Form
from services import ocr_service, transliteration

router = APIRouter()

@router.post("/")
async def transliterate(
    target_script: str = Form(...),
    file: UploadFile = None,
    text: str = Form(None)
):
    if file:
        extracted_text = await ocr_service.extract_text(file)
    else:
        extracted_text = text

    result = transliteration.convert_text(extracted_text, target_script)
    return {
        "status": "success",
        "source_text": extracted_text,
        "target_script": target_script,
        "transliterated_text": result
    }

