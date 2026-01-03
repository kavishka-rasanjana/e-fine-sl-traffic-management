const Station = require('../models/stationModel');
const Verification = require('../models/verificationModel');
const sendEmail = require('../utils/sendEmail');
const bcrypt = require('bcryptjs');
const Police = require('../models/policeModel');
const generateToken = require('../utils/generateToken');
const Driver = require('../models/driverModel');

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

// @desc    Verify OTP
// @route   POST /api/auth/verify-otp
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
  const { name, badgeNumber, email, password, station, otp, nic, phone, position, profileImage } = req.body;

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
      policeStation: station,
      position: position,
      profileImage: profileImage
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
    console.error("Register Error:", error.message);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// @desc    Register New Driver
// @route   POST /api/auth/register-driver
const registerDriver = async (req, res) => {
  const { name, nic, licenseNumber, email, phone, password } = req.body;

  try {
    const driverExists = await Driver.findOne({ email });
    if (driverExists) {
      return res.status(400).json({ message: 'Driver already registered' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const driver = await Driver.create({
      name,
      nic,
      licenseNumber,
      email,
      phone,
      password: hashedPassword,
    });

    if (driver) {
      res.status(201).json({
        success: true,
        _id: driver.id,
        name: driver.name,
        email: driver.email,
        role: 'driver',
        token: generateToken(driver.id),
      });
    } else {
      res.status(400).json({ message: 'Invalid driver data' });
    }

  } catch (error) {
    console.error("Driver Register Error:", error.message);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// @desc    Login User (Police or Driver)
// @route   POST /api/auth/login
// --- THIS FUNCTION IS UPDATED ---
const loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    let user = null;
    let role = '';

    const officer = await Police.findOne({ email });
    if (officer) {
      user = officer;
      role = officer.role || 'police';
    } else {
      const driver = await Driver.findOne({ email });
      if (driver) {
        user = driver;
        role = 'driver';
      }
    }

    if (user && (await bcrypt.compare(password, user.password))) {
      res.json({
        success: true,
        _id: user.id,
        name: user.name,
        email: user.email,
        role: role,
        badgeNumber: user.badgeNumber,

        // --- NEW FIELDS RETURNED FOR PROFILE ---
        position: user.position,
        policeStation: user.policeStation,
        profileImage: user.profileImage,

        isVerified: user.isVerified,
        licenseNumber: user.licenseNumber,
        nic: user.nic,

        token: generateToken(user.id),
      });
    } else {
      res.status(401).json({ message: 'Invalid email or password' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// @desc    Get Current User Data
// @route   GET /api/auth/me
// @access  Private
const getMe = async (req, res) => {
  try {
    const user = await Police.findById(req.user.id).select('-password');

    if (user) {
      res.status(200).json(user);
    } else {
      const driver = await Driver.findById(req.user.id).select('-password');
      if (driver) {
        res.status(200).json(driver);
      } else {
        res.status(404).json({ message: 'User not found' });
      }
    }
  } catch (error) {
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// @desc    Verify Driver by License Number (For Police)
// @route   PUT /api/auth/verify-driver
// @access  Private
const verifyDriver = async (req, res) => {
  const { licenseNumber } = req.body;

  try {
    const driver = await Driver.findOne({ licenseNumber }).select('-password');

    if (driver) {
      res.status(200).json({ success: true, data: driver });
    } else {
      res.status(404).json({ success: false, message: 'Driver not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// @desc    Update Profile Picture
// @route   PUT /api/auth/update-image
// @access  Private
const updateProfileImage = async (req, res) => {
  const id = req.body.id || req.user.id;
  const { profileImage } = req.body;

  try {
    let user = await Police.findByIdAndUpdate(id, { profileImage }, { new: true });

    if (!user) {
      user = await Driver.findByIdAndUpdate(id, { profileImage }, { new: true });
    }

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ success: true, message: 'Profile image updated successfully' });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

// ... Password Reset Functions ...

const forgotPassword = async (req, res) => {
  const { email } = req.body;
  try {
    let user = await Police.findOne({ email });
    if (!user) user = await Driver.findOne({ email });

    if (!user) return res.status(404).json({ message: 'User not found with this email' });

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    await Verification.deleteMany({ badgeNumber: email });
    await Verification.create({ badgeNumber: email, stationCode: 'RESET', otp });

    const message = `You requested a password reset. OTP: ${otp}`;
    await sendEmail({ email: user.email, subject: 'Password Reset Code', message });

    res.status(200).json({ success: true, message: 'OTP sent to email' });
  } catch (error) {
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

const verifyResetOTP = async (req, res) => {
  const { email, otp } = req.body;
  try {
    const record = await Verification.findOne({ badgeNumber: email, otp });
    if (!record) return res.status(400).json({ success: false, message: 'Invalid OTP' });
    res.status(200).json({ success: true, message: 'OTP Verified' });
  } catch (error) {
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

const resetPassword = async (req, res) => {
  const { email, newPassword, otp } = req.body;
  try {
    const record = await Verification.findOne({ badgeNumber: email, otp });
    if (!record) return res.status(400).json({ message: 'Invalid OTP' });

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    let updated = await Police.findOneAndUpdate({ email }, { password: hashedPassword });
    if (!updated) updated = await Driver.findOneAndUpdate({ email }, { password: hashedPassword });

    if (updated) {
      await Verification.deleteMany({ badgeNumber: email });
      res.status(200).json({ success: true, message: 'Password Reset Successful' });
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Server Error', error: error.message });
  }
};

module.exports = {
  requestVerification,
  verifyOTP,
  registerPolice,
  registerDriver,
  forgotPassword,
  verifyResetOTP,
  resetPassword,
  loginUser,
  getMe,
  verifyDriver,
  updateProfileImage
};