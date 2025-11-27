//D:\app_dev\GSTU_CSE_Connect\backend_api\src\routes\routineRoutes.js
const express = require('express');
const router = express.Router();
const {
    getRoutine,
    toggleClassStatus,
    addRoutine,
} = require('../controllers/routineController');

router.get('/', getRoutine);
router.post('/cancel', toggleClassStatus);
router.post('/add', addRoutine);

module.exports = router;