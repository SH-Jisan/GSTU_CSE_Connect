const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cloudinary = require('cloudinary').v2;
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

// 🟢 1. SIGNUP Logic (Updated: Added Phone)
exports.registerUser = async (req, res) => {
    // ⚠️ Phone রিসিভ করছি
    const { name, email, password, role, student_id, designation, session, phone } = req.body;

    try {
        const userCheck = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
        if (userCheck.rows.length > 0) {
            return res.status(400).json({ error: 'User already exists!' });
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        let assignedYear = '1st Year';
        let assignedSemester = '1st Semester';

        if (role === 'student' && session) {
            const batchCheck = await pool.query(
                "SELECT current_year, current_semester FROM users WHERE session = $1 AND role = 'student' LIMIT 1",
                [session]
            );

            if (batchCheck.rows.length > 0) {
                assignedYear = batchCheck.rows[0].current_year || '1st Year';
                assignedSemester = batchCheck.rows[0].current_semester || '1st Semester';
                console.log(`🔄 Auto-syncing new student to: ${assignedYear}, ${assignedSemester}`);
            }
        }

        // ⚠️ Insert Query: phone এবং is_phone_public (Default false) যোগ করা হলো
        const newUser = await pool.query(
            `INSERT INTO users (name, email, password_hash, role, student_id, session, designation, phone, is_phone_public, is_approved, current_year, current_semester)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) RETURNING *`,
            [name, email, hashedPassword, role, student_id, session, designation, phone, false, false, assignedYear, assignedSemester]
        );

        res.status(201).json({
            message: 'Registration successful! Please wait for Staff approval.',
            user: newUser.rows[0]
        });

    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: 'Server Error' });
    }
};

// 🔵 2. LOGIN Logic
exports.loginUser = async (req, res) => {
    const { email, password } = req.body;

    try {
        const user = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
        if (user.rows.length === 0) {
            return res.status(400).json({ error: 'Invalid Email or Password' });
        }

        const validPassword = await bcrypt.compare(password, user.rows[0].password_hash);
        if (!validPassword) {
            return res.status(400).json({ error: 'Invalid Email or Password' });
        }

        if (user.rows[0].is_approved === false) {
            return res.status(403).json({ error: 'Account Pending! Please wait for Staff approval.' });
        }

        const token = jwt.sign(
            { id: user.rows[0].id, role: user.rows[0].role },
            'SECRET_KEY_123',
            { expiresIn: '7d' }
        );

        res.json({ message: 'Login Successful', token, user: user.rows[0] });

    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: 'Server Error' });
    }
};

// 🟡 3. GET PROFILE Logic (Updated)
exports.getUserProfile = async (req, res) => {
    const { email } = req.body;
    try {
        // ⚠️ Phone এবং Privacy Info আনা হচ্ছে
        const user = await pool.query(
            'SELECT id, name, email, role, student_id, session, designation, is_cr, current_year, current_semester, avatar_url, phone, is_phone_public FROM users WHERE email = $1',
            [email]
        );

        if (user.rows.length === 0) {
            return res.status(404).json({ error: "User not found" });
        }

        res.json(user.rows[0]);

    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: "Server Error" });
    }
};

// ✏️ Profile Update Function (Updated)
exports.updateProfile = async (req, res) => {
    // ⚠️ Phone এবং is_phone_public রিসিভ করছি
    const { id, name, designation, phone, is_phone_public } = req.body;
    let image_base64 = req.body.image_base64;

    console.log("------------------------------------------------");
    console.log("📥 PROFILE UPDATE REQUEST RECEIVED");
    console.log("🆔 User ID:", id);
    console.log("📝 Text Data:", { name, designation, phone, is_phone_public });

    try {
        let avatar_url = req.body.avatar_url;

        if (image_base64) {
            console.log("📸 Uploading image...");
            try {
                const uploadRes = await cloudinary.uploader.upload(image_base64, {
                    upload_preset: 'ml_default',
                    folder: 'gstu_cse_profiles'
                });
                avatar_url = uploadRes.secure_url;
                console.log("✅ Cloudinary URL:", avatar_url);
            } catch (cloudErr) {
                console.error("❌ Cloudinary Error:", cloudErr);
            }
        }

        // ⚠️ Dynamic Query Update
        let query = "UPDATE users SET name = $1, designation = $2, phone = $3";
        let params = [name, designation, phone];
        let paramIndex = 4;

        // Privacy টগল আপডেট (যদি পাঠানো হয়)
        if (is_phone_public !== undefined) {
            query += `, is_phone_public = $${paramIndex}`;
            params.push(is_phone_public);
            paramIndex++;
        }

        if (avatar_url) {
            query += `, avatar_url = $${paramIndex}`;
            params.push(avatar_url);
            paramIndex++;
        }

        query += ` WHERE id = $${paramIndex} RETURNING *`;
        params.push(id);

        console.log("💾 Executing DB Query:", query);

        const update = await pool.query(query, params);

        if (update.rows.length === 0) {
            return res.status(404).json({ error: "User not found" });
        }

        console.log("✅ Database Updated.");
        res.json({ message: "Profile Updated", user: update.rows[0] });

    } catch (err) {
        console.error("❌ SERVER CRASH ERROR:", err.message);
        res.status(500).json({ error: "Server Error: " + err.message });
    }
};

// 🔔 FCM Token Update
exports.updateFcmToken = async (req, res) => {
    const { id, fcm_token } = req.body;
    try {
        await pool.query("UPDATE users SET fcm_token = $1 WHERE id = $2", [fcm_token, id]);
        res.json({ message: "Token Updated" });
    } catch (err) {
        console.error("Token Update Error:", err);
        res.status(500).json({ error: "Server Error" });
    }
};