const express = require('express');
const router = express.Router();
const { getPendingUsers, approveUser, rejectUser } = require('../controllers/staffController');

router.get('/pending', getPendingUsers);
router.post('/approve', approveUser);
router.post('/reject', rejectUser);

module.exports = router;