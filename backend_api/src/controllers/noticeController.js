//D:\app_dev\GSTU_CSE_Connect\backend_api\src\controllers\noticeController.js
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

const admin = require('../config/firebaseConfig');

// সব নোটিস পাওয়ার ফাংশন
exports.getAllNotices = async (req, res) => {
    try {
        // একদম নতুন নোটিস আগে দেখাবে (ORDER BY created_at DESC)
        const result = await pool.query('SELECT * FROM notices ORDER BY created_at DESC');
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};

// 🆕 নোটিস তৈরি করার ফাংশন
exports.addNotice = async (req, res) => {
    const { title, description, category, uploaded_by } = req.body;

    console.log("------------------------------------------------");
    console.log("📥 REQUEST RECEIVED: Add Notice");
    console.log(`📝 Title: ${title}, By User ID: ${uploaded_by}`);

    try {
        // 1. Database Insert
        console.log("💾 Inserting into Database...");
        const newNotice = await pool.query(
            "INSERT INTO notices (title, description, category, uploaded_by) VALUES ($1, $2, $3, $4) RETURNING *",
            [title, description, category, uploaded_by]
        );
        console.log("✅ Database Insert Success! ID:", newNotice.rows[0].id);

        // 2. Notification Logic
        console.log("🔔 Preparing Notification Payload...");
        try {
            // টপিক চেক (স্ট্রিং হতে হবে)
            const topicName = 'notices';

            const message = {
                notification: {
                    title: `New Notice: ${title}`,
                    body: description ? description.substring(0, 50) + "..." : "Check app for details",
                },
                topic: topicName
            };

            console.log("🚀 Sending to Firebase Topic:", topicName);

            // ফায়ারবেস সেন্ড কমান্ড
            const response = await admin.messaging().send(message);

            console.log("✅ FIREBASE SUCCESS! Response:", response);

        } catch (notifError) {
            console.error("❌ FIREBASE ERROR:", notifError);
            // এখানে আমরা থামব না, রেসপন্স পাঠিয়ে দেব
        }

        // 3. Response Send
        console.log("📤 Sending Response to Client");
        res.json(newNotice.rows[0]);

    } catch (err) {
        console.error("❌ CRITICAL SERVER ERROR:", err.message);
        res.status(500).json({ error: "Server Error" });
    }
};


// 🗑️ Notice Delete Function
exports.deleteNotice = async (req, res) => {
    const { id } = req.params; // URL theke ID nibo
    try {
        await pool.query("DELETE FROM notices WHERE id = $1", [id]);
        res.json({ message: "Notice Deleted Successfully" });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};

// ✏️ Notice Update Function
exports.updateNotice = async (req, res) => {
    const { id } = req.params; // কোন নোটিস আপডেট হবে
    const { title, description, category } = req.body; // নতুন ডাটা

    try {
        const update = await pool.query(
            "UPDATE notices SET title = $1, description = $2, category = $3 WHERE id = $4 RETURNING *",
            [title, description, category, id]
        );

        if (update.rows.length === 0) {
            return res.status(404).json({ error: "Notice not found" });
        }

        res.json({ message: "Notice Updated Successfully", notice: update.rows[0] });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};