const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

exports.getAllTeachers = async (req, res) => {
    try {
        // শুধু নাম, ইমেইল, পদবী এবং ছবি দরকার
        const result = await pool.query(
            "SELECT name, email, designation, avatar_url FROM users WHERE role = 'teacher' ORDER BY name ASC"
        );
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};