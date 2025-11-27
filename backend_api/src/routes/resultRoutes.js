//D:\app_dev\GSTU_CSE_Connect\backend_api\src\routes\resultRoutes.js
const express = require('express');
const router = express.Router();
const {
    getMyResults,
    addResult,
    updateResult,
    deleteResult,
} = require('../controllers/resultController');

// POST মেথড কারণ আমরা বডিতে ইমেইল পাঠাবো
router.post('/', getMyResults);
router.post('/add', addResult);
router.put('/:id', updateResult);
router.delete('/:id', deleteResult);

module.exports = router;