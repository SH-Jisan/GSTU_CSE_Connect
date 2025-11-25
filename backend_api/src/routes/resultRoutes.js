const express = require('express');
const router = express.Router();
const { getMyResults } = require('../controllers/resultController');

// POST মেথড কারণ আমরা বডিতে ইমেইল পাঠাবো
router.post('/', getMyResults);

module.exports = router;