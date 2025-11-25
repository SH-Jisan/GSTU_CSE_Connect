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