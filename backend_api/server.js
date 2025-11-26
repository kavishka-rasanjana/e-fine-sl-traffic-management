// 1. අවශ්‍ය පැකේජ් ගෙන්වා ගැනීම (Importing packages)
const express = require('express'); // Express framework එක ගෙන්වා ගැනීම
const dotenv = require('dotenv');   // .env ෆයිල් එක කියවන්න උදව් වෙන පැකේජ් එක

const connectDB = require('./config/db');

// 2. පරිසර විචල්‍යයන් (Environment Variables) සැකසීම
dotenv.config(); // .env ෆයිල් එකේ තියෙන දේවල් කියවලා load කරගන්නවා

connectDB();

// 3. Express යෙදවුම (App) ආරම්භ කිරීම
const app = express();

// 4. Middleware (අතරමැදි මෘදුකාංග) එකතු කිරීම
// මේකෙන් කියන්නේ අපේ සර්වර් එකට JSON ඩේටා (JSON data) තේරුම් ගන්න පුළුවන් වෙන්න ඕනේ කියලා.
// Frontend එකෙන් එවන ඩේටා කියවන්න මේක ඕනේ.
app.use(express.json());

// 5. සරල පරීක්ෂණ මාර්ගයක් (Test Route) සෑදීම
// කවුරුහරි අපේ සර්වර් එකේ මුල් පිටුවට (root URL එකට - '/') GET ඉල්ලීමක් කළොත්,
// අපි මේ function එක දුවනවා.
app.get('/', (req, res) => {
  // 'req' කියන්නේ ඉල්ලීම (request), 'res' කියන්නේ ප්‍රතිචාරය (response)
  res.send('API is running successfully!'); // අපි සාර්ථක බව පෙන්වන පණිවිඩයක් යවනවා.
});

// 6. සර්වර් එක ක්‍රියාත්මක කළ යුතු Port එක තීරණය කිරීම
// .env ෆයිල් එකේ PORT කියලා එකක් තියෙනවා නම් ඒක ගන්නවා, නැත්නම් 5000 පාවිච්චි කරනවා.
const PORT = process.env.PORT || 5000;

// 7. සර්වර් එක පණ ගැන්වීම (Starting the Server)
// සර්වර් එක පටන් ගත්තම, අපේ ටර්මිනල් එකේ පණිවිඩයක් පෙන්වනවා.
app.listen(PORT, () => {
  console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
});