const express = require('express');
const router = express.Router();
// Import all required functions from fineController only (avoid duplicate declarations)
const {
    getOffenses,
    addOffense,
    issueFine,
    getFineHistory,
    getDriverPendingFines
} = require('../controllers/fineController');

// URL: /api/fines/offenses (දඩ වර්ග ටික ගන්න)
router.get('/offenses', getOffenses);

// URL: /api/fines/add (Admin use only - අලුත් දඩ වර්ගයක් සිස්ටම් එකට දාන්න)
router.post('/add', addOffense);

// --- අලුත් Routes ---

// URL: /api/fines/issue (අලුත් දඩයක් ගහන්න - Data Save කරන්න)
router.post('/issue', issueFine);

// URL: /api/fines/history (ගහපු දඩ වල හිස්ට්‍රි එක ගන්න)
router.get('/history', getFineHistory);

// URL: /api/fines/pending (Driver ගේ Pending දඩ ගන්න)
router.get('/pending', getDriverPendingFines);

module.exports = router;

//update the route name
