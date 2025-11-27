//D:\app_dev\GSTU_CSE_Connect\backend_api\src\routes\courseRoutes.js
const express = require('express');
const router = express.Router();
const { getAllCourses, addCourse, updateCourse, deleteCourse } = require('../controllers/courseController');

router.get('/', getAllCourses);
router.post('/add', addCourse);
router.put('/:id', updateCourse);
router.delete('/:id', deleteCourse);

module.exports = router;