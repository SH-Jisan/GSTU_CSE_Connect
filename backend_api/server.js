require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

// রুট ইম্পোর্ট
const authRoutes = require('./src/routes/authRoutes');
const noticeRoutes = require('./src/routes/noticeRoutes');
const routineRoutes = require('./src/routes/routineRoutes');
const resultRoutes = require('./src/routes/resultRoutes');
const teacherRoutes = require('./src/routes/teacherRoutes');
const staffRoutes = require('./src/routes/staffRoutes');

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json()); // JSON ডাটা রিসিভ করার জন্য

// Routes ব্যবহার করা

// সব Auth রিকোয়েস্ট এখানে আসবে
app.use('/api/auth', authRoutes);
app.use('/api/notices', noticeRoutes);
app.use('/api/routines' , routineRoutes);
app.use('/api/results' , resultRoutes);
app.use('/api/teachers' , teacherRoutes);
app.use('/api/staff', staffRoutes);

// Database Test (Optional)
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});
pool.connect()
    .then(() => console.log('✅ Supabase Connected Successfully!'))
    .catch(err => console.error('❌ Connection Error:', err));

// Main Route
app.get('/', (req, res) => {
    res.send('🚀 GSTU CSE Backend is Running...');
});

// Start Server
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});