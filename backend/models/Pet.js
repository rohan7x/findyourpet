import mongoose from 'mongoose';

const petSchema = new mongoose.Schema({
  name: { type: String, required: true },
  type: { type: String, enum: ['lost', 'found'], required: true },
  breed: { type: String },
  description: { type: String },
  ownerName: { type: String },   
  ownerPhone: { type: String },  
  ownerEmail: { type: String },  
  ownerId: {
    type: String,
    required: function() { return this.type === 'lost'; }
  },
  reporterName: { type: String },    
  reporterPhone: { type: String },   
  reporterId: { type: String },      
  lastSeenDate: { type: Date, default: Date.now },
  address: { type: String },
  location: {
    type: { type: String, enum: ['Point'], default: 'Point' },
    coordinates: { type: [Number], default: [0, 0] }, // [longitude, latitude]
  },
  photoUrls: { type: [String] },
  createdAt: { type: Date, default: Date.now },
});

petSchema.index({ location: '2dsphere' }); // for geo queries

export default mongoose.model('Pet', petSchema);
