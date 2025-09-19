import pytesseract
from PIL import Image
import io

async def extract_text(file):
    image = Image.open(io.BytesIO(await file.read()))
    text = pytesseract.image_to_string(image, lang="hin+tam+tel+mal+pan")  # OCR for multiple Indic langs
    return text.strip()
