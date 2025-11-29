const express = require('express');
const router = express.Router();
const { getCurrentClassStudents, submitAttendance } = require('../controllers/attendanceController');

router.post('/check-class', getCurrentClassStudents); // স্মার্ট চেক
router.post('/submit', submitAttendance);             // সাবমিট

module.exports = router;