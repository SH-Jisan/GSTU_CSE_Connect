//D:\app_dev\GSTU_CSE_Connect\backend_api\src\controllers\resultController.js
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

// 🆕 রেজাল্ট আপলোড করার ফাংশন
exports.addResult = async (req, res) => {
    const { student_id_no, semester, course_code, gpa, grade, exam_year } = req.body;

    try {
        // ১. Student ID (Roll) দিয়ে আসল User ID বের করা
        const studentRes = await pool.query("SELECT id FROM users WHERE student_id = $1", [student_id_no]);

        if (studentRes.rows.length === 0) {
            return res.status(404).json({ error: "Student ID not found!" });
        }

        const db_user_id = studentRes.rows[0].id;

        // ২. রেজাল্ট ইনসার্ট করা
        const newResult = await pool.query(
            `INSERT INTO results (student_id, semester, course_code, gpa, grade, exam_year)
             VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
            [db_user_id, semester, course_code, gpa, grade, exam_year]
        );

        res.json({ message: "Result Uploaded Successfully!", result: newResult.rows[0] });

    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};

// ✏️ Result Update Function
exports.updateResult = async (req, res) => {
    const { id } = req.params; // রেজাল্ট ID
    const { course_code, gpa, grade } = req.body; // নতুন ডাটা

    try {
        const update = await pool.query(
            "UPDATE results SET course_code = $1, gpa = $2, grade = $3 WHERE id = $4 RETURNING *",
            [course_code, gpa, grade, id]
        );

        if (update.rows.length === 0) {
            return res.status(404).json({ error: "Result not found" });
        }

        res.json({ message: "Result Updated", result: update.rows[0] });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};

// 🗑️ Result Delete Function
exports.deleteResult = async (req, res) => {
    const { id } = req.params;
    try {
        await pool.query("DELETE FROM results WHERE id = $1", [id]);
        res.json({ message: "Result Deleted Successfully" });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};