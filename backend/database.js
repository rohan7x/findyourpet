import mongoose from 'mongoose';
import dotenv from 'dotenv';
dotenv.config();

const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/pettrack';

export async function connectDB() {
  try {
    await mongoose.connect(MONGO_URI, {
      // sensible options for modern mongoose
      autoIndex: true,
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000, // fail fast if server not reachable
      socketTimeoutMS: 45000,
    });
    console.log('MongoDB connected');
  } catch (err) {
    console.error('MongoDB connection error:', err);
    // exit so process manager / dev can show the error
    process.exit(1);
  }
}