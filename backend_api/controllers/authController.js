const Station = require('../models/stationModel');
const Verification = require('../models/verificationModel');
const sendEmail = require('../utils/sendEmail');
const bcrypt = require('bcryptjs');
const Police = require('../models/policeModel'); // Police Model 
const generateToken = require('../utils/generateToken');

// @desc    Request OTP for Police Registration
// @route   POST /api/auth/request-verification
// @access  Public
const requestVerification = async (req, res) => {
  const { badgeNumber, stationCode } = req.body;

  try {
   
    const station = await Station.findOne({ stationCode });

    if (!station) {
      return res.status(404).json({ message: 'Police Station not found' });
    }

    
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    
    await Verification.deleteMany({ badgeNumber });

    
    await Verification.create({
      badgeNumber,
      stationCode,
      otp, 
    });

    
const htmlMessage = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden;">
        
        <div style="background-color: #003366; padding: 20px; text-align: center;">
          <h2 style="color: #ffffff; margin: 0;">E-Fine SL Verification</h2>
        </div>

        <div style="padding: 20px; background-color: #ffffff;">
          <p style="font-size: 16px; color: #333;">Dear OIC,</p>
          <p style="font-size: 16px; color: #333;">The following officer has requested official registration access:</p>
          
          <table style="width: 100%; margin-bottom: 20px; background-color: #f9f9f9; padding: 10px; border-radius: 5px;">
            <tr>
              <td style="font-weight: bold; color: #555; padding: 5px;">Badge ID:</td>
              <td style="font-weight: bold; color: #000; padding: 5px;">${badgeNumber}</td>
            </tr>
            <tr>
              <td style="font-weight: bold; color: #555; padding: 5px;">Station:</td>
              <td style="font-weight: bold; color: #000; padding: 5px;">${station.name}</td>
            </tr>
          </table>

          <div style="text-align: center; margin: 30px 0;">
            <p style="margin: 0; font-size: 14px; color: #777;">VERIFICATION CODE (OTP)</p>
            <h1 style="margin: 10px 0; font-size: 40px; color: #003366; letter-spacing: 5px; font-weight: bold;">
              ${otp}
            </h1>
          </div>

          <p style="color: #d9534f; font-size: 14px; text-align: center; font-weight: bold;">
            ⚠️ Please verify the officer's identity before providing this code.
          </p>
        </div>

        <div style="background-color: #eeeeee; padding: 10px; text-align: center; font-size: 12px; color: #777;">
          © 2025 E-Fine SL Project | Secure Verification System
        </div>
      </div>
    `;


    await sendEmail({
      email: station.officialEmail,
      subject: 'Action Required: Officer Verification Code',
      message: `Your Verification Code is: ${otp}`, 
      html: htmlMessage, 
    });

    res.status(200).json({ success: true, message: `Verification code sent to OIC of ${station.name}` });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

const verifyOTP = async (req, res) => {
  const { badgeNumber, otp } = req.body;

  try {
    
    const record = await Verification.findOne({ badgeNumber, otp });

    if (!record) {
      return res.status(400).json({ success: false, message: 'Invalid or Expired OTP' });
    }

    
    res.status(200).json({ success: true, message: 'OTP Verified Successfully' });

  } catch (error) {
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// @desc    Register New Police Officer
// @route   POST /api/auth/register-police
const registerPolice = async (req, res) => {
  
  const { name, badgeNumber, email, password, station, otp, nic, phone } = req.body;

  try {
    const verifiedRecord = await Verification.findOne({ badgeNumber, otp });
    if (!verifiedRecord) {
      return res.status(401).json({ message: 'Unauthorized: Please verify OTP first' });
    }

    const officerExists = await Police.findOne({ badgeNumber });
    if (officerExists) {
      return res.status(400).json({ message: 'Officer already registered' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

   
    const officer = await Police.create({
      name,
      badgeNumber,
      email,
      nic,    
      phone,  
      password: hashedPassword,
      station,
    });

    await Verification.deleteMany({ badgeNumber });

    if (officer) {
      res.status(201).json({
        success: true,
        _id: officer.id,
        name: officer.name,
        email: officer.email,
        token: generateToken(officer.id),
      });
    } else {
      res.status(400).json({ message: 'Invalid officer data' });
    }

  } catch (error) {
    // 3. Terminal එකේ Error එක හරියට බලාගන්න මේ console.log එක දාන්න
    console.error("Register Error:", error.message); 
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// @desc    Login User (Police)
// @route   POST /api/auth/login
const loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    // 1. Check for police officer email
    const officer = await Police.findOne({ email });

    // 2. Check if officer exists AND password matches
    if (officer && (await bcrypt.compare(password, officer.password))) {
      res.json({
        success: true,
        _id: officer.id,
        name: officer.name,
        email: officer.email,
        role: officer.role, // 'officer' or 'admin'
        token: generateToken(officer.id),
      });
    } else {
      res.status(401).json({ message: 'Invalid email or password' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

module.exports = { requestVerification, verifyOTP, registerPolice, loginUser};