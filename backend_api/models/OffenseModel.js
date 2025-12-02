const mongoose = require('mongoose');

const offenseSchema = mongoose.Schema(
  {
    offenseName: {
      type: String,
      required: true,
      unique: true, // Ekama waradda deparak liyawenne na
    },
    amount: {
      type: Number,
      required: true,
    },
    description: {
      type: String,
      required: false,
    },
    sectionOfAct: { // Panatha (Example: 123-A)
      type: String,
      required: false, 
    }
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Offense', offenseSchema);