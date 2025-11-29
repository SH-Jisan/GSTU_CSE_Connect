//D:\app_dev\GSTU_CSE_Connect\backend_api\server.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

// ===== Middleware =====

// CORS only once
app.use(cors());

// Increase request size limit BEFORE routes
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ limit: "50mb", extended: true }));

// ===== Routes Import =====
const authRoutes = require('./src/routes/authRoutes');
const noticeRoutes = require('./src/routes/noticeRoutes');
const routineRoutes = require('./src/routes/routineRoutes');
const resultRoutes = require('./src/routes/resultRoutes');
const teacherRoutes = require('./src/routes/teacherRoutes');
const staffRoutes = require('./src/routes/staffRoutes');
const courseRoutes = require('./src/routes/courseRoutes');
const materialRoutes = require('./src/routes/materialRoutes');
const studentRoutes = require('./src/routes/studentRoutes');
const attendanceRoutes = require('./src/routes/attendanceRoutes');
// ===== Routes =====
app.use('/api/auth', authRoutes);
app.use('/api/notices', noticeRoutes);
app.use('/api/routines', routineRoutes);
app.use('/api/results', resultRoutes);
app.use('/api/teachers', teacherRoutes);
app.use('/api/staff', staffRoutes);
app.use('/api/courses', courseRoutes);
app.use('/api/materials', materialRoutes);
app.use('/api/student', studentRoutes);
app.use('./api/attendance', attendanceRoutes);

// ===== Database Connection =====
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});
pool.connect()
    .then(() => console.log('✅ Supabase Connected Successfully!'))
    .catch(err => console.error('❌ Connection Error:', err));

// ===== Main Route =====
app.get('/', (req, res) => {
    res.send('🚀 GSTU CSE Backend is Running...');
});

// ===== Start Server =====
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
