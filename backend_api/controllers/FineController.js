const Offense = require('../models/offenseModel');
const IssuedFine = require('../models/issuedFineModel'); // Step 1 දී අපි හදපු අලුත් Model එක මෙතනට ගන්නවා

// @desc    Get all fine types / offenses
// @route   GET /api/fines/offenses
// @access  Public (Mobile App)
const getOffenses = async (req, res) => {
  try {
    // Database eken okkoma offenses tika ganna
    const offenses = await Offense.find({}).sort({ offenseName: 1 }); // Namata anuwa piliwelata
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
    // Mobile App එකෙන් එවන Data ටික මෙතනට ගන්නවා
    const { licenseNumber, vehicleNumber, offenseId, offenseName, amount, place } = req.body;

    // Data හරියට ඇවිල්ලද බලනවා (Validation)
    if (!licenseNumber || !vehicleNumber || !offenseId || !place) {
        return res.status(400).json({ message: 'All fields are required (License, Vehicle, Offense, Place)' });
    }

    try {
        // Database එකේ "IssuedFines" කියන table එකට මේ data ටික save කරනවා
        const fine = await IssuedFine.create({
            licenseNumber,
            vehicleNumber,
            offenseId,
            offenseName,
            amount,
            place,
            // status සහ date ඉබේම වැටෙනවා model එකේ default දීලා තියෙන නිසා
        });

        // Save වුනාම සාර්ථක බව කියනවා (201 Created)
        res.status(201).json(fine); 
    } catch (error) {
        console.error("Error issuing fine:", error);
        res.status(500).json({ message: 'Failed to issue fine', error: error.message });
    }
};

// @desc    Get Fine History (Issued Fines List)
// @route   GET /api/fines/history
const getFineHistory = async (req, res) => {
    try {
        // Database එකෙන් ඔක්කොම දඩ ටික ගන්නවා.
        // .sort({ createdAt: -1 }) එකෙන් කියන්නේ අලුත්ම ඒවා ලිස්ට් එකේ උඩට එන්න ඕන කියන එක.
        const history = await IssuedFine.find({}).sort({ createdAt: -1 });
        
        res.status(200).json(history);
    } catch (error) {
        res.status(500).json({ message: 'Failed to get history', error: error.message });
    }
};

// අන්තිමට function හතරම export කරන්න ඕන
module.exports = { 
    getOffenses, 
    addOffense, 
    issueFine, 
    getFineHistory 
};