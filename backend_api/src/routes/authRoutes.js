//D:\app_dev\GSTU_CSE_Connect\backend_api\src\routes\authRoutes.js
const express = require('express');
const router = express.Router();
const {
    registerUser,
    loginUser,
    getUserProfile,
    updateProfile,
    updateFcmToken,
} = require('../controllers/authController');

// API Endpoints
router.post('/signup', registerUser); // লিংক হবে: /api/auth/signup
router.post('/login', loginUser);     // লিংক হবে: /api/auth/login
router.post('/profile' , getUserProfile);
router.put('/update', updateProfile); // এই লাইনটি থাকতেই হবে
router.put('/fcm-token', updateFcmToken);

module.exports = router;