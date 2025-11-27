const { Pool } = require('pg');
const cloudinary = require('cloudinary').v2;
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

// 📤 ম্যাটেরিয়াল আপলোড (Updated for Public/Private)
exports.uploadMaterial = async (req, res) => {
    // ⚠️ is_public রিসিভ করছি
    const { course_id, title, file_base64, file_type, uploaded_by, is_public } = req.body;

    console.log(`🚀 STARTING UPLOAD: ${title} (${file_type}) | Public: ${is_public}`);

    try {
        let file_url = "";

        if (file_base64) {
            let resourceType = 'auto';
            if (['pdf', 'doc', 'docx', 'ppt', 'pptx'].includes(file_type)) {
                resourceType = 'raw';
            } else if (['png', 'jpg', 'jpeg'].includes(file_type)) {
                resourceType = 'image';
            }

            const cleanTitle = title.replace(/[^a-zA-Z0-9]/g, "_");
            const uniqueName = `${Date.now()}_${cleanTitle}.${file_type}`;

            const uploadRes = await cloudinary.uploader.upload(file_base64, {
                upload_preset: 'ml_default',
                folder: 'gstu_cse_materials',
                resource_type: resourceType,
                public_id: uniqueName,
                use_filename: true,
                unique_filename: false
            });

            console.log("✅ Cloudinary URL:", uploadRes.secure_url);
            file_url = uploadRes.secure_url;
        }

        if (!file_url) {
            return res.status(400).json({ error: "File upload failed" });
        }

        // ⚠️ SQL Update: is_public কলামে ডাটা ঢুকাচ্ছি
        const newMaterial = await pool.query(
            "INSERT INTO materials (course_id, title, file_url, file_type, uploaded_by, is_public) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *",
            [course_id, title, file_url, file_type, uploaded_by, is_public]
        );

        res.json({ message: "Material Uploaded Successfully", material: newMaterial.rows[0] });

    } catch (err) {
        console.error("❌ UPLOAD ERROR:", err);
        res.status(500).json({ error: "Server Error: " + err.message });
    }
};

// 📥 নির্দিষ্ট কোর্সের ম্যাটেরিয়াল পাওয়া (Smart Filter)
exports.getMaterialsByCourse = async (req, res) => {
    const { courseId } = req.params;

    // ⚠️ কে রিকোয়েস্ট করছে তার ID নিচ্ছি (Query Parameter থেকে)
    // ফ্রন্টএন্ড থেকে পাঠাতে হবে: /api/materials/5?userId=10
    const { userId } = req.query;

    try {
        // লজিক:
        // ১. যদি is_public = true হয়, সবাই দেখবে।
        // ২. যদি is_public = false হয়, তবে শুধুমাত্র uploaded_by যার ID এর সাথে মিলবে সে দেখবে।

        const query = `
            SELECT materials.*, users.name as teacher_name
            FROM materials
            JOIN users ON materials.uploaded_by = users.id
            WHERE course_id = $1
            AND (is_public = TRUE OR uploaded_by = $2)
            ORDER BY created_at DESC
        `;

        // $1 = courseId, $2 = userId (যে দেখছে)
        const result = await pool.query(query, [courseId, userId || 0]);
        // userId না থাকলে 0 দিচ্ছি যাতে SQL এরর না দেয় (শুধু পাবলিক দেখাবে)

        res.json(result.rows);

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Server Error" });
    }
};

// 🗑️ ম্যাটেরিয়াল ডিলিট
exports.deleteMaterial = async (req, res) => {
    const { id } = req.params;
    try {
        await pool.query("DELETE FROM materials WHERE id = $1", [id]);
        res.json({ message: "Material Deleted" });
    } catch (err) {
        res.status(500).json({ error: "Server Error" });
    }
};

// 🔄 Toggle Public/Private Status
exports.toggleMaterialVisibility = async (req, res) => {
    const { id } = req.params;

    try {
        // Ager status check na korei SQL diye NOT kore dicchi
        const update = await pool.query(
            "UPDATE materials SET is_public = NOT is_public WHERE id = $1 RETURNING *",
            [id]
        );

        if (update.rows.length === 0) {
            return res.status(404).json({ error: "Material not found" });
        }

        res.json({ message: "Visibility Updated", material: update.rows[0] });

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Server Error" });
    }
};