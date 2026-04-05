# 🐾 PetTrack

PetTrack is a cross-platform application that helps users report **lost** and **found** pets.  
When users upload pet details and images, the system compares Lost vs Found entries and identifies potential matches using visual similarity scoring.

---

## Features

- Firebase Authentication for Login / Signup
- Add **Lost** or **Found** pet details
- Upload pet images through **Cloudinary**
- Location support for reporting
- Data stored securely in **MongoDB Atlas**
- Pet Match Scoring using **CLIP ViT-B/32** model (FastAPI backend)

---

## System Flow

Flutter App → Upload Pet + Image → Cloudinary (Image URL)
↓
Send Data to FastAPI Backend → MongoDB Atlas
↓
Matching Engine compares Lost vs Found → Generates match score

yaml
Copy code

![System Flow](./SystemFlow.png)

---

## Tech Stack

| Component | Technology |
|---------|------------|
| Frontend | Flutter |
| Authentication | Firebase Auth |
| Backend API | FastAPI |
| Database | MongoDB Atlas |
| Image Storage | Cloudinary |
| Similarity Model | CLIP ViT-B/32 (SentenceTransformers) |
| Geolocation Support | geopy |

---

## Folder Structure

PetTrack/
├── frontend/ # Flutter application
├── backend/ # FastAPI backend
│ ├── main.py
│ ├── matching_engine.py
│ ├── database.py
│ ├── models/
│ ├── utils.py
│ └── config.py
└── README.md

yaml
Copy code

---

## Configuration

Create `.env` inside `backend/`:

PORT=5000

MongoDB
MONGO_URI="<your_mongodb_atlas_connection_string>"

Cloudinary
CLOUDINARY_CLOUD_NAME="<your_cloud_name>"
CLOUDINARY_API_KEY="<your_api_key>"
CLOUDINARY_API_SECRET="<your_api_secret>"

Matching Engine
MATCHING_API_URL=http://localhost:8000/match_score
MATCH_THRESHOLD=0.7

Email (Optional)
EMAIL_USER="<email>"
EMAIL_PASS="<app_password>"

yaml
Copy code

---

## Backend Setup

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
API Docs: http://localhost:8000/docs

Frontend Setup (Flutter)
bash
Copy code
cd frontend
flutter pub get
flutter run
How Matching Works
When a Found pet is uploaded, backend fetches all Lost pets.

Both pet images are converted into vector embeddings using CLIP ViT-B/32.

Cosine similarity is computed.

If similarity ≥ threshold, the pair is marked as a match.

Matches appear in the Matches Screen.

Future Enhancements
Show uploader/owner details on each pet card

Auto-clean old lost pet entries (e.g., after 1–2 months)

Email notifications when a match occurs

Chat interface between owner and finder

“My Pets” section for managing uploaded pets

Screenshots (Click to View)
Login Screen
🔗 View Screenshot

Add Lost Pet Screen
🔗 View Screenshot

Add Found Pet Screen
🔗 View Screenshot

Matches Screen
🔗 View Screenshot