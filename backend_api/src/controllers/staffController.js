const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

// ১. সব পেন্ডিং রিকোয়েস্ট দেখার ফাংশন
exports.getPendingUsers = async (req, res) => {
    try {
        // যারা approved না, তাদের লিস্ট দাও
        const result = await pool.query("SELECT id, name, email, role, student_id, designation, created_at FROM users WHERE is_approved = false ORDER BY created_at DESC");
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};

// ২. ইউজার অ্যাপ্রুভ করার ফাংশন
exports.approveUser = async (req, res) => {
    const { id } = req.body; // যাকে অ্যাপ্রুভ করব তার ID
    try {
        await pool.query("UPDATE users SET is_approved = true WHERE id = $1", [id]);
        res.json({ message: "User Approved Successfully!" });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};

// ৩. ইউজার রিজেক্ট/ডিলিট করার ফাংশন (Optional)
exports.rejectUser = async (req, res) => {
    const { id } = req.body;
    try {
        await pool.query("DELETE FROM users WHERE id = $1", [id]);
        res.json({ message: "User Rejected & Removed" });
    } catch (err) {
        res.status(500).json({ error: "Server Error" });
    }
};

// 📋 সব স্টুডেন্টের লিস্ট (Search Directory এর জন্য)
exports.getAllStudents = async (req, res) => {
    try {
        const result = await pool.query(
            "SELECT id, name, email, student_id, session, avatar_url FROM users WHERE role = 'student' ORDER BY student_id ASC"
        );
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};