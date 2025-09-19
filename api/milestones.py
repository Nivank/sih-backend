from fastapi import APIRouter

router = APIRouter()

@router.get("/{user_id}")
def get_milestones(user_id: str):
    # TODO: Query DB for user stats
    return {
        "status": "success",
        "milestones": [
            {"type": "Scripts Read", "value": 3},
            {"type": "Locations Visited", "value": 5}
        ]
    }
