const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();

// ডাটাবেস কানেকশন (SSL সহ)
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
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
        /* if (!user.rows[0].is_approved) {
            return res.status(403).json({ error: 'Account not approved yet!' });
        }
        */

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

// ... আগের কোড ...

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