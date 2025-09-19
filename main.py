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
