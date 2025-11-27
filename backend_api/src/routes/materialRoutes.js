const express = require('express');
const router = express.Router();
const { uploadMaterial, getMaterialsByCourse, deleteMaterial,
    toggleMaterialVisibility,
} = require('../controllers/materialController');

router.post('/upload', uploadMaterial);      // ফাইল আপলোড
router.get('/:courseId', getMaterialsByCourse); // ফাইল দেখা (কোর্স আইডি দিয়ে)
router.delete('/:id', deleteMaterial);       // ফাইল ডিলিট
router.put('/toggle/:id', toggleMaterialVisibility);

module.exports = router;