const express = require('express');
const router = express.Router();
const {
    getMyResults,
    addResult,
} = require('../controllers/resultController');

// POST মেথড কারণ আমরা বডিতে ইমেইল পাঠাবো
router.post('/', getMyResults);
router.post('/add', addResult);

module.exports = router;