//D:\app_dev\GSTU_CSE_Connect\backend_api\src\routes\staffRoutes.js
const express = require('express');
const router = express.Router();
const {
    getPendingUsers,
    approveUser,
    rejectUser,
    getAllStudents,
 } = require('../controllers/staffController');

router.get('/pending', getPendingUsers);
router.post('/approve', approveUser);
router.post('/reject', rejectUser);
router.get('/students', getAllStudents);

module.exports = router;