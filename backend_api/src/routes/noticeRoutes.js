const express = require('express');
const router = express.Router();
const {
    getAllNotices,
    addNotice,
    deleteNotice,
    updateNotice,
} = require('../controllers/noticeController');

// GET request to /api/notices
router.get('/', getAllNotices);
router.post('/', addNotice);
router.delete('/:id', deleteNotice);
router.put('/:id', updateNotice);

module.exports = router;