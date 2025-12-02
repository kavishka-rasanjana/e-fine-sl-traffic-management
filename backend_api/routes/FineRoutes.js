const express = require('express');
const router = express.Router();
const { getOffenses, addOffense } = require('../controllers/fineController');

// URL: /api/fines/offenses
router.get('/offenses', getOffenses);

// URL: /api/fines/add (Admin use only)
router.post('/add', addOffense);

module.exports = router;