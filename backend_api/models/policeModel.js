const mongoose = require('mongoose');

const policeSchema = mongoose.Schema({
    // --- පරණ විස්තර ---
    name: { 
        type: String, 
        required: true 
    },
    email: { 
        type: String, 
        required: true, 
        unique: true 
    },
    badgeNumber: { 
        type: String, 
        required: true, 
        unique: true 
    },
    password: { 
        type: String, 
        required: true 
    },


    policeStation: { 
        type: String, 
        required: true 
    },
    position: { 
        type: String, 
        required: true //  OIC, Sergeant, Constable
    },
    profileImage: { 
        type: String, 
        default: 'https://cdn-icons-png.flaticon.com/512/206/206853.png' // Default පින්තූරයක්
    },

    // --- Role 
    role: { 
        type: String, 
        default: 'officer' 
    },
}, {
    timestamps: true
   });  // CreatedAt, UpdatedAt 


module.exports = mongoose.model('User', policeSchema);