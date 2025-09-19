from __future__ import annotations

from typing import List

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from db import get_db
from models import Note, User
from schemas import NoteCreate, NoteOut
from utils import get_current_user


router = APIRouter(prefix="/notes", tags=["notes"])


@router.post("/add", response_model=NoteOut)
def add_note(payload: NoteCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    note = Note(
        user_id=current_user.id,
        latitude=payload.latitude,
        longitude=payload.longitude,
        text=payload.text,
    )
    db.add(note)
    db.commit()
    db.refresh(note)
    return note


@router.get("/", response_model=List[NoteOut])
def list_notes(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    notes = db.query(Note).filter(Note.user_id == current_user.id).order_by(Note.created_at.desc()).all()
    return notes
