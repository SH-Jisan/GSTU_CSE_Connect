//D:\app_dev\GSTU_CSE_Connect\backend_api\src\routes\teacherRoutes.js
const express = require('express');
const router = express.Router();
const { getAllTeachers } = require('../controllers/teacherController');

router.get('/', getAllTeachers);

module.exports = router;