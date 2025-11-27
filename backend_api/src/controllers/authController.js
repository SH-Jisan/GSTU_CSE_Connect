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
    const { name, email, password, role, student_id } = req.body;

    try {
        // ১. চেক করি ইউজার আগে থেকেই আছে কিনা
        const userCheck = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
        if (userCheck.rows.length > 0) {
            return res.status(400).json({ error: 'User already exists!' });
        }

        // ২. পাসওয়ার্ড এনক্রিপ্ট (Hash) করা
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // ৩. ডাটাবেসে সেভ করা (ডিফল্টভাবে is_approved = false থাকবে)
        const newUser = await pool.query(
            'INSERT INTO users (name, email, password_hash, role, student_id) VALUES ($1, $2, $3, $4, $5) RETURNING id, name, email, role',
            [name, email, hashedPassword, role, student_id]
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
        if (!validPassword) {
            return res.status(400).json({ error: 'Invalid Email or Password' });
        }

        // ৩. চেক করা অ্যাডমিন অ্যাপ্রুভ করেছে কিনা
        // (টেস্টিংয়ের জন্য আপাতত এটা অফ রাখছি, পরে অন করব)
         if (!user.rows[0].is_approved) {
            return res.status(403).json({ error: 'Account pending!Please contact office staff!' });
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
            'SELECT id, name, email, role, student_id, session, designation, is_cr, avatar_url FROM users WHERE email = $1',
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

// profile update function(with image)
// ✏️ Profile Update Function (Fixed & Debugged)
exports.updateProfile = async (req, res) => {
    // 1. ডাটা রিসিভ
    const { id, name, designation } = req.body;
    let image_base64 = req.body.image_base64;

    console.log("📥 Update Request Received for User ID:", id);
    console.log("📝 Data:", { name, designation, hasImage: !!image_base64 });

    try {
        // 2. আইডি চেক
        if (!id) {
            console.log("❌ Error: User ID is missing!");
            return res.status(400).json({ error: "User ID is required" });
        }

        let avatar_url = req.body.avatar_url; // ডিফল্ট (যদি ইমেজ না আসে)

        // 3. ইমেজ আপলোড লজিক (যদি থাকে)
        if (image_base64) {
            console.log("📸 Uploading image to Cloudinary...");
            try {
                const uploadRes = await cloudinary.uploader.upload(image_base64, {
                    upload_preset: 'ml_default',
                    folder: 'gstu_cse_profiles'
                });
                avatar_url = uploadRes.secure_url;
                console.log("✅ Image Uploaded:", avatar_url);
            } catch (imgErr) {
                console.error("❌ Cloudinary Error:", imgErr);
                // ইমেজ ফেল করলেও টেক্সট আপডেট হবে, তাই রিটার্ন করছি না
            }
        }

        // 4. ডাটাবেস কুয়েরি (SQL)
        // আমরা এখানে COALESCE ব্যবহার করব না, সরাসরি লজিক দিয়ে আপডেট করব
        // যদি avatar_url না থাকে, তবে আগেরটাই রাখতে চাই। কিন্তু SQL এ সেটা হ্যান্ডেল করা কঠিন।
        // তাই আমরা ২টি আলাদা কুয়েরি বা লজিক ব্যবহার করতে পারি।
        // তবে সহজ সমাধানের জন্য: আমরা ধরে নিচ্ছি অ্যাপ আগের URL পাঠাবে না হলে আমরা আপডেট করব না।

        // সবচাইতে সেইফ কুয়েরি:
        let query = "UPDATE users SET name = $1, designation = $2";
        let params = [name, designation];
        let paramIndex = 3;

        // যদি নতুন ছবি থাকে তবেই URL আপডেট করব
        if (avatar_url) {
            query += `, avatar_url = $${paramIndex}`;
            params.push(avatar_url);
            paramIndex++;
        }

        query += ` WHERE id = $${paramIndex} RETURNING *`;
        params.push(id);

        const update = await pool.query(query, params);

        if (update.rows.length === 0) {
            console.log("❌ Error: User not found in DB");
            return res.status(404).json({ error: "User not found" });
        }

        console.log("✅ Database Updated Successfully");
        res.json({ message: "Profile Updated", user: update.rows[0] });

    } catch (err) {
        console.error("❌ Server Error:", err.message);
        res.status(500).json({ error: "Server Error" });
    }
};