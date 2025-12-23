const mongoose = require('mongoose');
const dotenv = require('dotenv');
require('colors');
const bcrypt = require('bcryptjs'); // Password Hash කරන්න මේක ඕන

// වැදගත්: ඔයාගේ Model ෆයිල් එකේ නම policeModel.js නම් path එක හරියටම දෙන්න
const User = require('./models/policeModel'); 

dotenv.config(); // .env ෆයිල් එක ලෝඩ් කරනවා

// දත්ත ඇතුළත් කිරීමේ ෆන්ෂන් එක
const importData = async () => {
  try {
    // 1. පරණ දත්ත මකනවා (Clean Start)
    await User.deleteMany(); 

    console.log('Old data cleared...'.yellow);

    // 2. Password එක Hash (Encrypt) කරගන්නවා
    // (නිකන්ම '1234' කියලා දැම්මොත් Login වෙද්දී වැරදියි කියල වැටෙයි)
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash('1234', salt);

    // 3. අලුත් විස්තර සහිත User (Officer) කෙනෙක් හදනවා
    await User.create([
      {
        name: 'Kavishka Rasanjana',
        email: 'kavi@police.lk',
        badgeNumber: 'COP-1234',
        password: hashedPassword, // Hash කරපු පාස්වර්ඩ් එක
        
        // --- අලුත් විස්තර ---
        policeStation: 'Matara Police Station',
        position: 'Traffic Sergeant',
        profileImage: 'https://randomuser.me/api/portraits/men/32.jpg', // Sample Photo URL
        
        role: 'officer'
      }
    ]);

    console.log('Data Imported Successfully!'.green.inverse);
    process.exit();
  } catch (error) {
    console.error(`Error: ${error.message}`.red.inverse);
    process.exit(1);
  }
};

// දත්ත මකා දැමීමේ ෆන්ෂන් එක
const destroyData = async () => {
  try {
    await User.deleteMany();
    console.log('Data Destroyed!'.red.inverse);
    process.exit();
  } catch (error) {
    console.error(`${error}`.red.inverse);
    process.exit(1);
  }
};

// ඩේටාබේස් එකට සම්බන්ධ වීම සහ වැඩේ පටන් ගැනීම
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB Connected for Seeder...'.cyan.underline);
    
    // කමාන්ඩ් එක අනුව වැඩ කරන විදිහ තීරණය කිරීම
    if (process.argv[2] === '-d') {
      destroyData();
    } else {
      importData();
    }
  })
  .catch((err) => {
    console.error(`Error: ${err.message}`.red);
    process.exit(1);
  });