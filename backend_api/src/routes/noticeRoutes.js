const express = require('express');
const router = express.Router();
const {
    getAllNotices,
    addNotice,
} = require('../controllers/noticeController');

// GET request to /api/notices
router.get('/', getAllNotices);
router.post('/', addNotice);

module.exports = router;