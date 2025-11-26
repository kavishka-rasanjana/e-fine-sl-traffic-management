// config/db.js

// Mongoose පැකේජ් එක ගෙන්වා ගැනීම
const mongoose = require('mongoose');

// ඩේටාබේස් එක සම්බන්ධ කරන asynchronous function එක
const connectDB = async () => {
  try {
    // .env ෆයිල් එකෙන් MONGO_URI එක අරගෙන සම්බන්ධ වෙනවා
    const conn = await mongoose.connect(process.env.MONGO_URI);

    // සාර්ථක වුනොත් ටර්මිනල් එකේ පණිවිඩයක් පෙන්වනවා
    console.log(`MongoDB Connected: ${conn.connection.host}`);

  } catch (error) {
    // සම්බන්ධ වෙන්න බැරි වුනොත් දෝෂය පෙන්වලා සර්වර් එක නවත්තනවා
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
};

// මේ function එක අනිත් ෆයිල් වලට පාවිච්චි කරන්න පුළුවන් විදිහට export කරනවා
module.exports = connectDB;