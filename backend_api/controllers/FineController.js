const Offense = require('../models/offenseModel');

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

module.exports = { getOffenses, addOffense };