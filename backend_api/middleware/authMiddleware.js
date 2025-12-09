const jwt = require('jsonwebtoken');
const Driver = require('../models/driverModel');
const Police = require('../models/policeModel');

const protect = async (req, res, next) => {
  let token;

  //check is there token in header
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      // "Bearer <token>" 
      // break and take 
      token = req.headers.authorization.split(' ')[1];

      // 2.  Verify the token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

    
     // find the user by id in token 
   
      //first check if user is drver or not
      let user = await Driver.findById(decoded.id).select('-password');
      
      // if not driver then check if police
      if (!user) {
        user = await Police.findById(decoded.id).select('-password');
      }

      req.user = user;
      next(); 

    } catch (error) {
      console.error(error);
      res.status(401).json({ message: 'Not authorized, token failed' });
    }
  }

  if (!token) {
    res.status(401).json({ message: 'Not authorized, no token' });
  }
};

module.exports = { protect };