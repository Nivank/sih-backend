from __future__ import annotations
from __future__ import annotations

from typing import List
import base64

from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, Response
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
import io

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


@router.post("/add-with-photo", response_model=NoteOut)
async def add_note_with_photo(
    text: str = Form(...),
    latitude: float = Form(...),
    longitude: float = Form(...),
    photo: UploadFile = File(...),
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    """Add a note with an attached photo."""
    
    # Validate photo
    content_type = getattr(photo, 'content_type', None)
    if not content_type or not content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    # Read photo data
    photo_data = await photo.read()
    
    # Create note with photo
    note = Note(
        user_id=current_user.id,
        latitude=latitude,
        longitude=longitude,
        text=text,
        photo_data=photo_data,
        photo_filename=photo.filename,
        photo_content_type=photo.content_type,
    )
    
    db.add(note)
    db.commit()
    db.refresh(note)
    
    return note


@router.get("/", response_model=List[NoteOut])
def list_notes(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    notes = db.query(Note).filter(Note.user_id == current_user.id).order_by(Note.created_at.desc()).all()
    
    # Add has_photo field to each note
    notes_with_photo_info = []
    for note in notes:
        photo_data = getattr(note, 'photo_data', None)
        note_dict = {
            "id": note.id,
            "latitude": note.latitude,
            "longitude": note.longitude,
            "text": note.text,
            "photo_filename": getattr(note, 'photo_filename', None),
            "photo_content_type": getattr(note, 'photo_content_type', None),
            "has_photo": photo_data is not None,
            "created_at": note.created_at
        }
        notes_with_photo_info.append(note_dict)
    
    return notes_with_photo_info


@router.get("/{note_id}/photo")
def get_note_photo(
    note_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get the photo associated with a note."""
    
    note = db.query(Note).filter(
        Note.id == note_id,
        Note.user_id == current_user.id
    ).first()
    
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    
    photo_data = getattr(note, 'photo_data', None)
    if photo_data is None:
        raise HTTPException(status_code=404, detail="No photo found for this note")
    
    # Return photo as streaming response
    content_type = getattr(note, 'photo_content_type', None) or "image/jpeg"
    filename = getattr(note, 'photo_filename', None) or 'photo.jpg'
    
    return StreamingResponse(
        io.BytesIO(photo_data),
        media_type=content_type,
        headers={"Content-Disposition": f"inline; filename={filename}"}
    )