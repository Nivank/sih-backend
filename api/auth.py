from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

class UserAuth(BaseModel):
    email: str
    password: str

@router.post("/register")
def register(user: UserAuth):
    # TODO: Save user in DB
    return {"status": "success", "message": "User registered"}

@router.post("/login")
def login(user: UserAuth):
    # TODO: Validate user & return JWT token
    return {"status": "success", "token": "dummy_jwt_token"}
