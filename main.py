from fastapi import FastAPI
from api import auth, ocr, notes, tourism, milestones

app = FastAPI(title="Bharat Transliteration App API")

# Register routers
app.include_router(auth.router, prefix="/auth", tags=["Auth"])
app.include_router(ocr.router, prefix="/transliterate", tags=["OCR/Transliteration"])
app.include_router(notes.router, prefix="/notes", tags=["Notes"])
app.include_router(tourism.router, prefix="/tourist", tags=["Tourism"])
app.include_router(milestones.router, prefix="/milestones", tags=["Milestones"])

@app.get("/")
def root():
    return {"message": "Bharat Transliteration API is running 🚀"}
