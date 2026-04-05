import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import petsRouter from './routes/pets.js';
import matchesRouter from './routes/matches.js';
import { connectDB } from './database.js';

dotenv.config();

const app = express();
app.use(cors({ origin: true, credentials: true }));
app.use(express.json());

app.use('/pets', petsRouter);
app.use('/pets/matches', matchesRouter);

const port = process.env.PORT || 5000;

(async () => {
  await connectDB();
 // app.listen(port, () => console.log(`Server running on http://localhost:${port}`));
 app.listen(port, "0.0.0.0", () =>
  console.log(`✅ Server running on http://${process.env.HOST || "0.0.0.0"}:${port}`)
);

})();
