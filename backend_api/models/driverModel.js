const mongoose = require('mongoose');

const driverSchema = mongoose.Schema(
  {
    name: { type: String, required: true },
    nic: { type: String, required: true, unique: true },
    licenseNumber: { type: String, required: true, unique: true }, 
    email: { type: String, required: true, unique: true },
    phone: { type: String, required: true },
    password: { type: String, required: true },
    role: { type: String, default: 'driver' }, // 'driver'
    
    // (Demerit Points)
    demeritPoints: { type: Number, default: 0 }, 
    licenseStatus: { type: String, enum: ['Active', 'Suspended'], default: 'Active' },

    isVerified: { type: Boolean, default: false },
    // ...
    licenseExpiryDate: { type: String }, 
    licenseIssueDate: { type: String }, // 4a
    dateOfBirth: { type: String }, // 3
    
    address: { type: String },
    city: { type: String },
    postalCode: { type: String },
    

    vehicleClasses: [{
        category: String, // A, B, B1
        issueDate: String,
        expiryDate: String
    }],
    // ...
  },
  { timestamps: true }
);

module.exports = mongoose.model('Driver', driverSchema);