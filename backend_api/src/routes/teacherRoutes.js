const express = require('express');
const router = express.Router();
const { getAllTeachers } = require('../controllers/teacherController');

router.get('/', getAllTeachers);

module.exports = router;