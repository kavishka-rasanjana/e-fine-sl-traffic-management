const express = require('express');
const router = express.Router();

// Controller එකෙන් අවශ්‍ය ඔක්කොම Functions මෙතනට Import කරගන්නවා
const { 
  requestVerification, 
  verifyOTP, 
  registerPolice,
  registerDriver,
  loginUser,
  forgotPassword,
  verifyResetOTP,
  resetPassword,
  getMe,
  verifyDriver,
  updateProfileImage // <--- 1. මේක අලුතෙන් එකතු කළා
} = require('../controllers/authController');

const { protect } = require('../middleware/authMiddleware');

// Public Routes
router.post('/request-verification', requestVerification);
router.post('/verify-otp', verifyOTP);      
router.post('/register-police', registerPolice);
router.post('/register-driver', registerDriver);
router.post('/login', loginUser);
router.post('/forgot-password', forgotPassword);
router.post('/verify-reset-otp', verifyResetOTP);
router.post('/reset-password', resetPassword);

// Private Routes (Token අවශ්‍යයි)
router.get('/me', protect, getMe);
router.put('/verify-driver', protect, verifyDriver);

// --- 2. Profile Image Update Route එක (Step 2) ---
router.put('/update-image', updateProfileImage); 

module.exports = router;