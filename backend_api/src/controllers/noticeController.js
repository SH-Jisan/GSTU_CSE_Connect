const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

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

    try {
        const newNotice = await pool.query(
            "INSERT INTO notices (title, description, category, uploaded_by) VALUES ($1, $2, $3, $4) RETURNING *",
            [title, description, category, uploaded_by]
        );
        res.json(newNotice.rows[0]);
    } catch (err) {
        console.error(err.message);
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