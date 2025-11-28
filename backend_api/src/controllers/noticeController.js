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
    const newNotice = await pool.query(
                "INSERT INTO notices (title, description, category, uploaded_by) VALUES ($1, $2, $3, $4) RETURNING *",
                [title, description, category, uploaded_by]
    );
    try {
                const message = {
                    notification: {
                        title: `New Notice: ${title}`,
                        body: description.substring(0, 100) + "...", // ছোট প্রিভিউ
                    },
                    topic: 'notices' // যারা এই টপিকে আছে সবাই পাবে
                };

                await admin.messaging().send(message);
                console.log("🔔 Notification Sent Successfully!");
            } catch (notifError) {
                console.error("❌ Notification Failed:", notifError);
            }

            res.json(newNotice.rows[0]);
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