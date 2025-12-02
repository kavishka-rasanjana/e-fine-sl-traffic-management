const mongoose = require('mongoose');

const stationSchema = mongoose.Schema(
  {
    stationCode: {
      type: String,
      required: true,
      unique: true, 
      
    },
    name: {
      type: String,
      required: true, 
    },
    district: {
      type: String,
      required: true,
    },
    officialEmail: {
      type: String,
      required: true, 
      
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Station', stationSchema);