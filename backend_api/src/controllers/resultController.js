const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

exports.getMyResults = async (req, res) => {
    const { email } = req.body; // অ্যাপ ইমেইল পাঠাবে

    try {
        const query = `
            SELECT * FROM results
            WHERE student_id = (SELECT id FROM users WHERE email = $1)
            ORDER BY semester DESC; -- লেটেস্ট রেজাল্ট আগে দেখাবে
        `;
        const result = await pool.query(query, [email]);

        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};