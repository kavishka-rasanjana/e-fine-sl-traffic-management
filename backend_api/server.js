const express = require('express'); 
const dotenv = require('dotenv');   
const connectDB = require('./config/db');

dotenv.config(); 

connectDB();

const app = express();

// --- මෙන්න මේ වෙනස කරන්න (50mb දක්වා ඉඩ දෙනවා) ---
app.use(express.json({ limit: '50mb' })); 
app.use(express.urlencoded({ limit: '50mb', extended: true }));
// ----------------------------------------------------

// Routes
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/stations', require('./routes/stationRoutes'));
app.use('/api/fines', require('./routes/fineRoutes')); // ඔයා fineRoutes ෆයිල් එක හදලා නම් මේක වැඩ කරයි

app.get('/', (req, res) => {
  res.send('API is running successfully!'); 
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
});