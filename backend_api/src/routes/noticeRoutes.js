const express = require('express');
const router = express.Router();
const {
    getAllNotices,
    addNotice,
    deleteNotice,
} = require('../controllers/noticeController');

// GET request to /api/notices
router.get('/', getAllNotices);
router.post('/', addNotice);
router.delete('/:id', deleteNotice);

module.exports = router;