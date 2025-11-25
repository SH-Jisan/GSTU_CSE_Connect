const express = require('express');
const router = express.Router();
const {
    getRoutine,
    toggleClassStatus,
} = require('../controllers/routineController');

router.get('/', getRoutine);
router.post('/cancel', toggleClassStatus);

module.exports = router;