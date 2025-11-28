const express = require('express');
const router = express.Router();
const { updateSemester } = require('../controllers/studentController');

router.put('/update-semester', updateSemester);

module.exports = router;