const express = require('express');
const router = express.Router();

// Controller එකෙන් අවශ්‍ය ඔක්කොම Functions එකම තැනක Import කරගන්න
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
  updateProfileImage 
} = require('../controllers/authController');

// Middleware එක හරියටම import කරගන්න (Folder එකේ නම ගැන සැලකිලිමත් වන්න)
const { protect } = require('../middleware/authMiddleware');

// --- Routes ---

router.post('/request-verification', requestVerification);
router.post('/verify-otp', verifyOTP);      
router.post('/register-police', registerPolice);
router.post('/register-driver', registerDriver);
router.post('/login', loginUser);
router.post('/forgot-password', forgotPassword);
router.post('/verify-reset-otp', verifyResetOTP);
router.post('/reset-password', resetPassword);

// Protected Routes (Login වෙලා ඉන්න ඕන)
router.get('/me', protect, getMe);
router.put('/verify-driver', protect, verifyDriver);
router.put('/update-profile-image', protect, updateProfileImage);

module.exports = router;