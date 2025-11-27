//D:\app_dev\GSTU_CSE_Connect\backend_api\src\controllers\routineController.js
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

// রুটিন পাওয়ার ফাংশন
exports.getRoutine = async (req, res) => {
    try {
        // SQL JOIN কুয়েরি: routines টেবিলের সাথে users টেবিল জোড়া লাগানো হচ্ছে টিচারের নাম পাওয়ার জন্য
        const query = `
            SELECT routines.*, users.name as teacher_name
            FROM routines
            JOIN users ON routines.teacher_id = users.id
            ORDER BY
                CASE
                    WHEN day = 'Sunday' THEN 1
                    WHEN day = 'Monday' THEN 2
                    WHEN day = 'Tuesday' THEN 3
                    WHEN day = 'Wednesday' THEN 4
                    WHEN day = 'Thursday' THEN 5
                    ELSE 6
                END,
                start_time ASC;
        `;

        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};

// 🔴 ক্লাস ক্যানসেল বা একটিভ করার ফাংশন
exports.toggleClassStatus = async (req, res) => {
    const { id } = req.body; // ক্লাসের routine_id আসবে

    try {
        // স্ট্যাটাস উল্টে দেওয়া (True থাকলে False, False থাকলে True)
        const query = `
            UPDATE routines
            SET is_cancelled = NOT is_cancelled
            WHERE id = $1
            RETURNING *;
        `;
        const result = await pool.query(query, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: "Class not found" });
        }

        res.json({ message: "Class status updated", class: result.rows[0] });

    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};

// 🆕 নতুন ক্লাস যোগ করার ফাংশন
exports.addRoutine = async (req, res) => {
    const { semester, course_code, course_title, teacher_email, room_no, day, start_time, end_time } = req.body;

    try {
        // ১. টিচারের ইমেইল দিয়ে টিচারের ID খুঁজে বের করা
        const teacherRes = await pool.query("SELECT id FROM users WHERE email = $1", [teacher_email]);

        if (teacherRes.rows.length === 0) {
            return res.status(404).json({ error: "Teacher email not found!" });
        }

        const teacher_id = teacherRes.rows[0].id;

        // ২. রুটিন টেবিল-এ ডাটা ঢুকানো
        const newRoutine = await pool.query(
            `INSERT INTO routines (semester, course_code, course_title, teacher_id, room_no, day, start_time, end_time)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
            [semester, course_code, course_title, teacher_id, room_no, day, start_time, end_time]
        );

        res.json({ message: "Class Added Successfully!", routine: newRoutine.rows[0] });

    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};