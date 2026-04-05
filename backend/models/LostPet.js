import mongoose from "mongoose";

const lostPetSchema = new mongoose.Schema({
  name: { type: String, required: true },
  type: { type: String },
  description: { type: String },
  userEmail: { type: String, required: true }, // logged-in user's email
  contactNumber: { type: String, required: true }, // extra contact
  createdAt: { type: Date, default: Date.now },
});

const LostPet = mongoose.model("LostPet", lostPetSchema);
export default LostPet;
