from fastapi import APIRouter

router = APIRouter()

@router.get("/nearby")
def get_nearby(lat: float, lon: float):
    # TODO: Call Google Maps / Places API
    return {
        "status": "success",
        "places": [
            {"name": "India Gate", "type": "Monument", "distance_km": 1.2},
            {"name": "Rashtrapati Bhavan", "type": "Heritage Building", "distance_km": 3.5}
        ]
    }
