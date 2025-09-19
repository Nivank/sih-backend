from __future__ import annotations

from datetime import datetime
from typing import Optional, List

from pydantic import BaseModel, EmailStr, Field


# Auth
class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(min_length=6)


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    user_id: int


# Notes
class NoteCreate(BaseModel):
    latitude: float
    longitude: float
    text: str


class NoteOut(BaseModel):
    id: int
    latitude: float
    longitude: float
    text: str
    created_at: datetime

    class Config:
        from_attributes = True


# Transliteration
class TransliterateTextIn(BaseModel):
    source_text: str
    source_script: Optional[str] = None
    target_script: str


class TransliterateOut(BaseModel):
    source_text: str
    source_script: str
    target_script: str
    transliterated_text: str
