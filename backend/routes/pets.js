import express from "express";
import upload from "../middleware/upload.js";
import { addLostPet, addFoundPet, getPets } from "../controllers/petsController.js";

const router = express.Router();

// Single POST /pets route with multer
router.post("/", upload, (req, res) => {
  const type = req.body.type?.toLowerCase();
  if (!type) return res.status(400).json({ error: "Missing type (lost/found)" });

  if (type === "lost") return addLostPet(req, res);
  if (type === "found") return addFoundPet(req, res);

  return res.status(400).json({ error: "Invalid type, must be 'lost' or 'found'" });
});

// Get pets
router.get("/", getPets);

export default router;
