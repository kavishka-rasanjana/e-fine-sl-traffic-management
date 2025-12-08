const Offense = require('../models/offenseModel');
const IssuedFine = require('../models/issuedFineModel'); 

// @desc    Get all fine types / offenses
// @route   GET /api/fines/offenses
// @access  Public (Mobile App)
const getOffenses = async (req, res) => {
  try {
    const offenses = await Offense.find({}).sort({ offenseName: 1 }); 
    res.status(200).json(offenses);
  } catch (error) {
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// @desc    Add a new offense (For Admin Testing)
// @route   POST /api/fines/add
const addOffense = async (req, res) => {
  const { offenseName, amount, description } = req.body;
  try {
    const offense = await Offense.create({ offenseName, amount, description });
    res.status(201).json(offense);
  } catch (error) {
    res.status(500).json({ message: 'Failed to add offense', error: error.message });
  }
};

// ==========================================================
// පහතින් ඇඩ් කරේ අලුත් කොටස් දෙක (Issue Fine & History)
// ==========================================================

// @desc    Issue a new fine (Save to Database)
// @route   POST /api/fines/issue
const issueFine = async (req, res) => {
    // 1. policeOfficerId කියන එකත් අලුතෙන් body එකෙන් ගන්නවා
    const { licenseNumber, vehicleNumber, offenseId, offenseName, amount, place, policeOfficerId } = req.body;

    // Data හරියට ඇවිල්ලද බලනවා (Validation)
    // policeOfficerId එකත් අනිවාර්ය කරනවා
    if (!licenseNumber || !vehicleNumber || !offenseId || !place || !policeOfficerId) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    try {
        // Database එකට save කරනවා
        const fine = await IssuedFine.create({
            licenseNumber,
            vehicleNumber,
            offenseId,
            offenseName,
            amount,
            place,
            policeOfficerId, // දඩේ ගැහුවේ කවුද කියලා මෙතනින් Save වෙනවා
            // status සහ date ඉබේම වැටෙනවා
        });

        res.status(201).json(fine); 
    } catch (error) {
        console.error("Error issuing fine:", error);
        res.status(500).json({ message: 'Failed to issue fine', error: error.message });
    }
};

// @desc    Get Fine History (Filter by Officer ID)
// @route   GET /api/fines/history
const getFineHistory = async (req, res) => {
    try {
        // 2. URL එකෙන් එවන Officer ID එක ගන්නවා (උදා: ?officerId=badge123)
        const { officerId } = req.query; 

        // officerId එකක් එව්වා නම් ඒ අයට අදාල ඒවා විතරක් සොයනවා. 
        // නැත්නම් ({}) ඔක්කොම පෙන්නනවා.
        const query = officerId ? { policeOfficerId: officerId } : {};

        // අලුත්ම ඒවා උඩට එන විදිහට sort කරනවා
        const history = await IssuedFine.find(query).sort({ createdAt: -1 });
        
        res.status(200).json(history);
    } catch (error) {
        res.status(500).json({ message: 'Failed to get history', error: error.message });
    }
};

module.exports = { 
    getOffenses, 
    addOffense, 
    issueFine, 
    getFineHistory 
};