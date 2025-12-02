// config/db.js

//assign mongoose to a variable
const mongoose = require('mongoose');

//function of connect to the database
const connectDB = async () => {
  try {

    //connect MONGO URI in env
    const conn = await mongoose.connect(process.env.MONGO_URI);

    //If success then show in terminal
    console.log(`MongoDB Connected: ${conn.connection.host}`);

  } catch (error) {

    //when cannot connect to the database then show the error ans stop the server
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
};

module.exports = connectDB;