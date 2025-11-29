const Station = require('../models/stationModel');

// @desc    Get all police stations
// @route   GET /api/stations
const getStations = async (req, res) => {
  try {
    
    const stations = await Station.find().select('name stationCode');
    res.status(200).json(stations);
  } catch (error) {
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

module.exports = { getStations };