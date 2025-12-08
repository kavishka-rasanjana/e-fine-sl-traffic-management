const express = require('express');
const router = express.Router();

// 1. Controller එකෙන් අලුත් functions දෙකත් (issueFine, getFineHistory) මෙතනට import කරගන්න ඕන.
const { 
    getOffenses, 
    addOffense, 
    issueFine, 
    getFineHistory 
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

module.exports = router;