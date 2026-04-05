import mongoose from "mongoose";
const matchSchema = new mongoose.Schema({
  lostPet: { type: mongoose.Schema.Types.ObjectId, ref: "Pet", required: true },
  foundPet: { type: mongoose.Schema.Types.ObjectId, ref: "Pet", required: true },
  score: { type: Number, required: true },
  createdAt: { type: Date, default: Date.now },
});

export default mongoose.model("Match", matchSchema);
