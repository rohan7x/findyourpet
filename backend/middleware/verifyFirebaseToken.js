// middleware/verifyFirebaseToken.js
import admin from '../config/firebase.js';

export default async function verifyFirebaseToken(req, res, next) {
    try {
        if (process.env.SKIP_AUTH === 'true') {
            console.log('⚠️ SKIP_AUTH=true — skipping token verification (development only).');
            req.user = { uid: req.body?.ownerId || 'dev-user' }; // fallback for development
            return next();
        }

        const token = req.headers.authorization?.split('Bearer ')[1];
        if (!token) {
            return res.status(401).json({ error: 'No token provided' });
        }

        const decodedToken = await admin.auth().verifyIdToken(token);
        req.user = { uid: decodedToken.uid };
        next();
    } catch (error) {
        console.error('Firebase token verification failed:', error);
        res.status(401).json({ error: 'Unauthorized' });
    }
}
