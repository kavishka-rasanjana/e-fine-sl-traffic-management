const mongoose = require('mongoose');

const verificationSchema = mongoose.Schema({
  badgeNumber: { type: String, required: true }, 
  stationCode: { type: String, required: true }, 
  otp: { type: String, required: true }, 
  createdAt: { type: Date, default: Date.now, expires: 600 }
});

module.exports = mongoose.model('Verification', verificationSchema);