const express = require('express');
const router = express.Router();
const {
    registerUser,
    loginUser,
    getUserProfile,
    updateProfile,
} = require('../controllers/authController');

// API Endpoints
router.post('/signup', registerUser); // লিংক হবে: /api/auth/signup
router.post('/login', loginUser);     // লিংক হবে: /api/auth/login
router.post('/profile' , getUserProfile);
router.put('/update', updateProfile); // এই লাইনটি থাকতেই হবে

module.exports = router;