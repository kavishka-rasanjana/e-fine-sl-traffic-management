
const express = require('express'); 
const dotenv = require('dotenv');   

const connectDB = require('./config/db');


dotenv.config(); 

connectDB();


const app = express();



app.use(express.json());

// Routes
app.use('/api/auth', require('./routes/authRoutes'));

app.use('/api/stations', require('./routes/stationRoutes'));

app.use('/api/fines', require('./routes/fineRoutes'));

app.get('/', (req, res) => {
 
  res.send('API is running successfully!'); 
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
});