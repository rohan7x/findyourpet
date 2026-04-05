from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.routing import APIRoute
from models.pet import Pet
from matching_engine import match_score
from database import pets_collection, matches_collection
from bson import ObjectId

app = FastAPI()

# Allow frontend origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5000",
        "http://localhost:8000",
        "http://localhost:4200",
        "http://localhost:8080",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def _get_status_from_pet(pet_dict):
    # Support both `status` and `type`
    return pet_dict.get("status") or pet_dict.get("type")


@app.on_event("startup")
async def _log_routes():
    print("FastAPI routes:")
    for route in app.router.routes:
        if isinstance(route, APIRoute):
            print(f"  PATH: {route.path}  METHODS: {sorted(route.methods)}")
    print("Docs: http://localhost:8000/docs (or change port)")


# POST /pets - add lost or found pet
@app.post("/pets")
def add_pet(pet: Pet):
    pet_dict = pet.dict()
    status = _get_status_from_pet(pet_dict)
    if not status:
        raise HTTPException(status_code=400, detail="Missing pet status/type")

    # Normalize image fields
    if "image_url" not in pet_dict and "photoUrls" in pet_dict and pet_dict["photoUrls"]:
        pet_dict["image_url"] = pet_dict["photoUrls"][0]
    if "photoUrls" not in pet_dict and "image_url" in pet_dict:
        pet_dict["photoUrls"] = [pet_dict["image_url"]]

    inserted = pets_collection.insert_one(pet_dict)
    pet_id = inserted.inserted_id

    # Run matches only if it's a found pet
    if str(status).lower() == "found":
        lost_pets = list(pets_collection.find({"$or": [{"status": "lost"}, {"type": "lost"}]}))
        created_matches = []
        for lost in lost_pets:
            # ensure lost has image_url
            if "image_url" not in lost and "photoUrls" in lost and lost["photoUrls"]:
                lost["image_url"] = lost["photoUrls"][0]

            score_val = match_score(lost, pet_dict)
            if score_val >= 0.85:  # strict threshold
                match_doc = {
                    "lost_pet_id": lost["_id"],
                    "found_pet_id": pet_id,
                    "match_score": score_val,
                }
                matches_collection.insert_one(match_doc)
                pets_collection.delete_one({"_id": lost["_id"]})
                created_matches.append({
                    "lost_pet_id": str(lost["_id"]),
                    "found_pet_id": str(pet_id),
                    "match_score": score_val,
                })

        return {"message": "Found pet added", "pet_id": str(pet_id), "matches": created_matches}

    return {"message": "Pet added", "pet_id": str(pet_id)}



# GET /pets - list pets (optional filter ?type=lost|found)
@app.get("/pets")
def get_pets(type: str = None):
    query = {}
    if type and type.lower() in ("lost", "found"):
        query["$or"] = [{"type": type.lower()}, {"status": type.lower()}]
    docs = list(pets_collection.find(query).sort("createdAt", -1))
    out = []
    for d in docs:
        d["_id"] = str(d["_id"])
        out.append(d)
    return out


# GET /pets/matches - view all matches
@app.get("/pets/matches")
def get_matches():
    docs = list(matches_collection.find().sort("match_score", -1))
    out = []
    for m in docs:
        out.append({
            "_id": str(m.get("_id")),
            "lost_pet_id": str(m.get("lost_pet_id")),
            "found_pet_id": str(m.get("found_pet_id")),
            "match_score": m.get("match_score"),
        })
    return {"matches": out}


# ✅ NEW: POST /pets/matches - run live matching for a found/lost pet
@app.post("/pets/matches")
def post_matches(payload: dict):
    """
    Accepts a pet payload and returns list of potential matches
    """
    pet_data = payload.get("pet")
    pet_type = str(payload.get("type", "")).lower()

    if not pet_data:
        raise HTTPException(status_code=400, detail="Missing pet data")

    query_type = "lost" if pet_type == "found" else "found"
    other_pets = list(pets_collection.find({
        "$or": [{"type": query_type}, {"status": query_type}]
    }))

    matches = []
    for other in other_pets:
        try:
            score = match_score(pet_data, other)
            score_val = float(score)
        except Exception as e:
            print("Error computing match:", e)
            continue

        if score_val >= 0.7:
            matches.append({
                "id": str(other["_id"]),
                "score": score_val
            })

    return {"matches": matches}


@app.post("/match_score")
async def match_score_api(request: Request):
    data = await request.json()
    pet_data = data.get("pet")
    if not pet_data:
        raise HTTPException(status_code=400, detail="Missing pet data")

    # ensure image_url exists
    if "image_url" not in pet_data and "photoUrls" in pet_data and pet_data["photoUrls"]:
        pet_data["image_url"] = pet_data["photoUrls"][0]

    lost_pets = list(pets_collection.find({"$or": [{"status": "lost"}, {"type": "lost"}]}))
    out_matches = []

    for lost in lost_pets:
        if "image_url" not in lost and "photoUrls" in lost and lost["photoUrls"]:
            lost["image_url"] = lost["photoUrls"][0]

        try:
            score_val = float(match_score(lost, pet_data))
        except Exception as e:
            print("Matching error:", e)
            continue

        if score_val >= 0.7:
            out_matches.append({
                "lostId": str(lost["_id"]),
                "score": score_val
            })

    # ⚡ Node expects a **list** not an object with 'matches'
    return out_matches


@app.get("/matches/count")
def get_reunited_count():
    count = matches_collection.count_documents({})
    return {"reunited_count": count}

