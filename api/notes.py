from fastapi import APIRouter
from pydantic import BaseModel
from typing import List

router = APIRouter()

class Note(BaseModel):
    user_id: str
    latitude: float
    longitude: float
    note: str

notes_db: List[Note] = []

@router.post("/add")
def add_note(note: Note):
    notes_db.append(note)
    return {"status": "success", "message": "Note saved"}

@router.get("/{user_id}")
def get_notes(user_id: str):
    user_notes = [n for n in notes_db if n.user_id == user_id]
    return {"status": "success", "notes": user_notes}
