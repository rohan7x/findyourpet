# database.py
from pymongo import MongoClient
from config import MONGO_URI, DB_NAME

client = MongoClient(MONGO_URI)
db = client[DB_NAME]

pets_collection = db["pets"]
matches_collection = db["matches"]
