//D:\app_dev\GSTU_CSE_Connect\backend_api\src\controllers\courseController.js
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

// 📋 সব কোর্স পাওয়ার ফাংশন
exports.getAllCourses = async (req, res) => {
    try {
        const result = await pool.query("SELECT * FROM courses ORDER BY semester ASC, course_code ASC");
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};

// 🆕 নতুন কোর্স অ্যাড করার ফাংশন
exports.addCourse = async (req, res) => {
    const { course_code, course_title, semester, syllabus } = req.body;

    try {
        // ডুপ্লিকেট চেক
        const check = await pool.query("SELECT * FROM courses WHERE course_code = $1", [course_code]);
        if (check.rows.length > 0) {
            return res.status(400).json({ error: "Course Code already exists!" });
        }

        const newCourse = await pool.query(
            "INSERT INTO courses (course_code, course_title, semester, syllabus) VALUES ($1, $2, $3, $4) RETURNING *",
            [course_code, course_title, semester, syllabus]
        );

        res.json({ message: "Course Added", course: newCourse.rows[0] });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};

// ✏️ কোর্স আপডেট ফাংশন
exports.updateCourse = async (req, res) => {
    const { id } = req.params;
    const { course_code, course_title, semester, syllabus } = req.body;

    try {
        const update = await pool.query(
            "UPDATE courses SET course_code = $1, course_title = $2, semester = $3, syllabus = $4 WHERE id = $5 RETURNING *",
            [course_code, course_title, semester, syllabus, id]
        );
        res.json({ message: "Course Updated", course: update.rows[0] });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};

// 🗑️ কোর্স ডিলিট ফাংশন
exports.deleteCourse = async (req, res) => {
    const { id } = req.params;
    try {
        await pool.query("DELETE FROM courses WHERE id = $1", [id]);
        res.json({ message: "Course Deleted" });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};