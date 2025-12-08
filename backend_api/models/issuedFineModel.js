const mongoose = require('mongoose');

const issuedFineSchema = mongoose.Schema({
    licenseNumber: { type: String, required: true },
    vehicleNumber: { type: String, required: true },
    offenseId: { type: mongoose.Schema.Types.ObjectId, ref: 'Offense', required: true }, // දඩ වර්ගය
    offenseName: { type: String, required: true }, // ලේසියට නම save කරගමු
    amount: { type: Number, required: true },
    place: { type: String, required: true },
    policeOfficerId: { type: String, default: "Officer-001" }, // දැනට hardcode කරමු
    status: { type: String, default: "Unpaid" }, // ගෙව්වද නැද්ද කියන එක
    date: { type: Date, default: Date.now } // දඩ ගැහුව වෙලාව
}, {
    timestamps: true
});

module.exports = mongoose.model('IssuedFine', issuedFineSchema);