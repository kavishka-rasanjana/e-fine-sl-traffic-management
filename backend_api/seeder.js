const mongoose = require('mongoose');
const dotenv = require('dotenv');
require('colors'); // colors කෙලින්ම මෙහෙම ගන්න
const Station = require('./models/stationModel');
const stations = require('./models/_data/stations.json');

dotenv.config(); // .env ෆයිල් එක ලෝඩ් කරනවා

// දත්ත ඇතුළත් කිරීමේ ෆන්ෂන් එක
const importData = async () => {
  try {
    await Station.deleteMany(); // පරණ දත්ත මකනවා
    await Station.insertMany(stations); // අලුත් දත්ත දානවා
    console.log('Data Imported Successfully!'.green.inverse);
    process.exit();
  } catch (error) {
    console.error(`${error}`.red.inverse);
    process.exit(1);
  }
};

// දත්ත මකා දැමීමේ ෆන්ෂන් එක
const destroyData = async () => {
  try {
    await Station.deleteMany();
    console.log('Data Destroyed!'.red.inverse);
    process.exit();
  } catch (error) {
    console.error(`${error}`.red.inverse);
    process.exit(1);
  }
};

// --- ප්‍රධාන වෙනස මෙතනයි ---
// අපි මුලින්ම ඩේටාබේස් එකට සම්බන්ධ වෙනවා.
// සම්බන්ධතාවය සාර්ථක වුනොත් විතරක් ඊළඟ පියවරට යනවා.
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