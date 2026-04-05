import mongoose from "mongoose";

const foundPetSchema = new mongoose.Schema({
  name: { type: String, required: true },
  type: { type: String },
  description: { type: String },
  createdAt: { type: Date, default: Date.now },
});

const FoundPet = mongoose.model("FoundPet", foundPetSchema);
export default FoundPet;
