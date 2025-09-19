<<<<<<< HEAD
from __future__ import annotations

import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from db import engine, Base
from api.auth import router as auth_router
from api.translit import router as translit_router
from api.notes import router as notes_router


# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Bharat Transliteration App - Backend MVP")


# CORS configuration
frontend_origin = os.getenv("FRONTEND_ORIGIN", "*")
app.add_middleware(
    CORSMiddleware,
    allow_origins=[frontend_origin] if frontend_origin != "*" else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {"message": "Bharat Transliteration API is running"}


# Include routers
app.include_router(auth_router)
app.include_router(translit_router)
app.include_router(notes_router)
=======
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
>>>>>>> 2bf4bd62af1039d142c8e491bf8c3cbff80d61d4
