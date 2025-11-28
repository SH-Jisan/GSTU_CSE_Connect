const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

// 🎓 Update Semester (Smart Logic)
exports.updateSemester = async (req, res) => {
    const { id, year, semester } = req.body;

    try {
        // 1. Check User Role & Session
        const userRes = await pool.query("SELECT * FROM users WHERE id = $1", [id]);

        if (userRes.rows.length === 0) {
            return res.status(404).json({ error: "User not found" });
        }

        const user = userRes.rows[0];

        // 2. Logic: Jodi CR hoy, tobe puro Session update hobe
        if (user.is_cr) {
            console.log(`🚀 CR Action: Promoting entire session ${user.session} to ${year} ${semester}`);

            await pool.query(
                "UPDATE users SET current_year = $1, current_semester = $2 WHERE session = $3 AND role = 'student'",
                [year, semester, user.session]
            );

            res.json({ message: `Full Batch (${user.session}) Promoted to ${year} ${semester}!` });
        }
        // 3. Logic: Jodi Normal Student hoy, shudhu nijer ta update hobe
        else {
            console.log(`👤 Student Action: Updating self to ${year} ${semester}`);

            await pool.query(
                "UPDATE users SET current_year = $1, current_semester = $2 WHERE id = $3",
                [year, semester, id]
            );

            res.json({ message: "Your Profile Updated Successfully" });
        }

    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};