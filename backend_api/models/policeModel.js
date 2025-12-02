const mongoose = require('mongoose');

const policeSchema = mongoose.Schema(
  {
    name: { type: String, required: true },
    badgeNumber: { type: String, required: true, unique: true },
    email: { type: String, required: true, unique: true },
   
    nic: { type: String, required: true }, // NIC 
    phone: { type: String, required: true }, // Phone Number 
    // ------------------
    password: { type: String, required: true },
    station: { type: String, required: true },
    role: { type: String, enum: ['officer', 'admin'], default: 'officer' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Police', policeSchema);