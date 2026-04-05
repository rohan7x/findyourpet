import Match from '../models/Match.js';
import Pet from '../models/Pet.js';

export const getMatches = async (req, res) => {
  try {
    const matches = await Match.find()
      .sort({ createdAt: -1 })
      .populate('foundPet')
      .populate('lostPet')
      .lean();
    return res.status(200).json(matches);
  } catch (err) {
    console.error('getMatches error', err);
    return res.status(500).json({ error: 'Failed to fetch matches' });
  }
};