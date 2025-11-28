//D:\app_dev\GSTU_CSE_Connect\backend_api\src\controllers\authController.js
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cloudinary = require('cloudinary').v2;
require('dotenv').config();

// ডাটাবেস কানেকশন (SSL সহ)
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

// 🟢 1. SIGNUP Logic
exports.registerUser = async (req, res) => {
    const { name, email, password, role, student_id, designation, session} = req.body;

    try {
        // ১. চেক করি ইউজার আগে থেকেই আছে কিনা
        const userCheck = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
        if (userCheck.rows.length > 0) {
            return res.status(400).json({ error: 'User already exists!' });
        }

        // ২. পাসওয়ার্ড এনক্রিপ্ট (Hash) করা
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

         let assignedYear = '1st Year';
         let assignedSemester = '1st Semester';
         if (role === 'student' && session) {
                     // Database e check kori ey session er onno kew ache kina
                     const batchCheck = await pool.query(
                         "SELECT current_year, current_semester FROM users WHERE session = $1 AND role = 'student' LIMIT 1",
                         [session]
                     );

                     if (batchCheck.rows.length > 0) {
                         // Batchmate pawa gese! Tader year/sem copy koro
                         assignedYear = batchCheck.rows[0].current_year || '1st Year';
                         assignedSemester = batchCheck.rows[0].current_semester || '1st Semester';
                         console.log(`🔄 Auto-syncing new student to: ${assignedYear}, ${assignedSemester}`);
                     }
                 }
        // ৩. ডাটাবেসে সেভ করা (ডিফল্টভাবে is_approved = false থাকবে)
        const newUser = await pool.query(
                    `INSERT INTO users (name, email, password_hash, role, student_id, session, designation, is_approved, current_year, current_semester)
                     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *`,
                    [name, email, hashedPassword, role, student_id, session, designation, false, assignedYear, assignedSemester]
                );



        res.status(201).json({
            message: 'Registration successful! Please wait for Admin approval.',
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
        // ১. ইউজার খোঁজা
        const user = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
        if (user.rows.length === 0) {
            return res.status(400).json({ error: 'Invalid Email or Password' });
        }

        // ২. পাসওয়ার্ড মেলানো
        const validPassword = await bcrypt.compare(password, user.rows[0].password_hash);

        if (user.rows[0].is_approved === false) {
                    return res.status(403).json({ error: 'Account Pending! Please wait for Staff approval.' });
                }




        // ৪. টোকেন জেনারেট করা (এটি দিয়ে অ্যাপ ইউজারকে চিনবে)
        const token = jwt.sign(
            { id: user.rows[0].id, role: user.rows[0].role },
            'SECRET_KEY_123', // বাস্তবে এটা .env ফাইলে রাখতে হয়
            { expiresIn: '7d' }
        );

        res.json({ message: 'Login Successful', token, user: user.rows[0] });

    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: 'Server Error' });
    }
};

// 🟡 3. GET PROFILE Logic
exports.getUserProfile = async (req, res) => {
    const { email } = req.body; // অ্যাপ থেকে ইমেইল আসবে

    try {
        // পাসওয়ার্ড ছাড়া বাকি সব তথ্য দাও
        const user = await pool.query(
            'SELECT id, name, email, role, student_id, session, designation, is_cr, current_year, current_semester, avatar_url FROM users WHERE email = $1',
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

// ✏️ Profile Update Function (Deep Debug Mode)
exports.updateProfile = async (req, res) => {
    const { id, name, designation } = req.body;
    let image_base64 = req.body.image_base64;

    console.log("------------------------------------------------");
    console.log("📥 PROFILE UPDATE REQUEST RECEIVED");
    console.log("🆔 User ID:", id);
    console.log("📝 Text Data:", { name, designation });

    // ইমেজ আসছে কিনা চেক
    if (image_base64) {
        console.log("📸 Image Base64 Length:", image_base64.length);
        console.log("📸 Image Preview:", image_base64.substring(0, 30) + "...");
    } else {
        console.log("⚠️ No Image Data Received from App!");
    }

    try {
        let avatar_url = req.body.avatar_url; // আগের URL (যদি থাকে)

        // 1. Cloudinary Upload Attempt
        if (image_base64) {
            console.log("☁️ Attempting Cloudinary Upload...");
            try {
                const uploadRes = await cloudinary.uploader.upload(image_base64, {
                    upload_preset: 'ml_default',
                    folder: 'gstu_cse_profiles'
                });

                if (uploadRes && uploadRes.secure_url) {
                    avatar_url = uploadRes.secure_url;
                    console.log("✅ Cloudinary Success! New URL:", avatar_url);
                } else {
                    console.log("❌ Cloudinary Uploaded but returned no URL.");
                }
            } catch (cloudErr) {
                console.error("❌ CLOUDINARY UPLOAD FAILED:", cloudErr);
                // আমরা এখানে থামব না, দেখব কেন ফেইল হলো
            }
        }

        // 2. Database Update Attempt
        console.log("💾 Updating Database with URL:", avatar_url);

        // ডাইনামিক কুয়েরি (যাতে ভুল না হয়)
        const update = await pool.query(
            "UPDATE users SET name = $1, designation = $2, avatar_url = $3 WHERE id = $4 RETURNING *",
            [name, designation, avatar_url, id]
        );

        if (update.rows.length === 0) {
            console.log("❌ DB Error: User ID not found during update.");
            return res.status(404).json({ error: "User not found" });
        }

        console.log("✅ Database Updated. Returning User:", update.rows[0]);
        res.json({ message: "Profile Updated", user: update.rows[0] });

    } catch (err) {
        console.error("❌ SERVER CRASH ERROR:", err.message);
        res.status(500).json({ error: "Server Error: " + err.message });
    }
};

// 🔔 FCM Token আপডেট করার ফাংশন
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