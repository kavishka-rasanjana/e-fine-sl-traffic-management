const express = require('express');
const router = express.Router();
const { requestVerification, 
  verifyOTP, 
  registerPolice,
  registerDriver,
  loginUser,
  forgotPassword,
  verifyResetOTP,
  resetPassword
} = require('../controllers/authController');

router.post('/request-verification', requestVerification);
router.post('/verify-otp', verifyOTP);      
router.post('/register-police', registerPolice);
router.post('/register-driver', registerDriver);
router.post('/login', loginUser);
router.post('/forgot-password', forgotPassword);
router.post('/verify-reset-otp', verifyResetOTP);
router.post('/reset-password', resetPassword);


module.exports = router;