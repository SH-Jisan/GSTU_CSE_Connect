const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

// 🕵️ Smart Fetch: বর্তমান ক্লাস এবং স্টুডেন্ট লিস্ট বের করা
exports.getCurrentClassStudents = async (req, res) => {
    const { teacherId, day, time } = req.body;
    // time format: "10:30" (24 hour or AM/PM handled by logic logic if needed, but best is HH:mm:ss)
    // আমরা ফ্রন্টএন্ড থেকে শুধু 'Sunday' বা 'Monday' পাঠাবো।

    try {
        console.log(`🔎 Checking class for Teacher: ${teacherId} on ${day} at ${time}`);

        // ১. চেক করি এই স্যারের এখন কোনো ক্লাস আছে কিনা
        // SQL Time Comparison: বর্তমান সময় কি start এবং end এর মাঝে?
        const routineQuery = `
            SELECT * FROM routines
            WHERE teacher_id = $1
            AND day = $2
            AND $3::time BETWEEN start_time AND end_time
        `;

        const routineRes = await pool.query(routineQuery, [teacherId, day, time]);

        if (routineRes.rows.length === 0) {
            return res.json({
                found: false,
                message: "No active class found at this time!"
            });
        }

        // ক্লাস পাওয়া গেছে!
        const activeClass = routineRes.rows[0];
        console.log("✅ Active Class Found:", activeClass.course_code);

        // ২. এখন ওই সেমিস্টারের সব স্টুডেন্টকে খুঁজে বের করি
        // (যাদের current_year এবং current_semester রুটিনের সাথে মিলবে)
        // রুটিনে semester রাখা আছে "1st Year 1st Sem" ফরমেটে।
        // আর ইউজারের আছে current_year="1st Year", current_semester="1st Semester"
        // তাই আমাদের একটু স্ট্রিং ম্যাচিং করতে হবে অথবা রুটিনের সেমিস্টার স্ট্রিংটাই ব্যবহার করব।

        // *টিপ:* আমরা ধরে নিচ্ছি রুটিনের 'semester' কলামে যা আছে (e.g. '1st Year 1st Sem'),
        // আমরা ইউজারের ডাটাবেস থেকে সেইম ফরম্যাটে স্টুডেন্ট আনব।
        // অথবা সহজ উপায়: আমরা ইউজারের current_year এবং current_semester যোগ করে ম্যাচ করব।

        // লজিক: রুটিনের সেমিস্টার স্ট্রিং এর সাথে ম্যাচ করা
        // উদাহরণ: Routine='1st Year 1st Sem' | User: Year='1st Year', Sem='1st Semester' (একটু অমিল আছে 'Sem' vs 'Semester')
        // তাই আমরা LIKE অপারেটর ব্যবহার করব।

        const targetSem = activeClass.semester; // e.g. "1st Year 1st Sem"

        // এখানে আমরা একটু ট্রিক করছি: সেমিস্টারের প্রথম কিছু অংশ দিয়ে ম্যাচ করছি
        const studentsQuery = `
            SELECT id, name, student_id, avatar_url
            FROM users
            WHERE role = 'student'
            AND is_approved = true
            AND $1 LIKE '%' || current_year || '%' -- Year মিলতে হবে
            AND $1 LIKE '%' || REPLACE(current_semester, 'Semester', '') || '%' -- 'Semester' শব্দটা বাদ দিয়ে ম্যাচ করছি (Sem vs Semester)
            ORDER BY student_id ASC
        `;

        const studentsRes = await pool.query(studentsQuery, [targetSem]);

        res.json({
            found: true,
            classInfo: activeClass,
            students: studentsRes.rows
        });

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Server Error" });
    }
};

// 💾 অ্যাটেনডেন্স সাবমিট করা
exports.submitAttendance = async (req, res) => {
    const { teacher_id, course_code, semester, date, records } = req.body;
    // records হবে একটা array: [{student_id: 1, status: 'Present'}, ...]

    const client = await pool.connect(); // ট্রানজেকশন শুরু

    try {
        await client.query('BEGIN');

        for (const record of records) {
            // আগে চেক করি আজ অলরেডি দিয়েছে কিনা, দিলে আপডেট, না দিলে ইনসার্ট (Upsert Logic)
            // সিম্পল রাখার জন্য আমরা সরাসরি ইনসার্ট করছি, ডুপ্লিকেট আটকাতে চাইলে পরে লজিক দেব
            await client.query(
                `INSERT INTO attendance (date, student_id, teacher_id, course_code, semester, status)
                 VALUES ($1, $2, $3, $4, $5, $6)`,
                [date, record.student_id, teacher_id, course_code, semester, record.status]
            );
        }

        await client.query('COMMIT'); // সব সেভ
        res.json({ message: "Attendance Submitted Successfully!" });

    } catch (err) {
        await client.query('ROLLBACK'); // এরর হলে সব বাতিল
        console.error(err);
        res.status(500).json({ error: "Failed to submit attendance" });
    } finally {
        client.release();
    }
};