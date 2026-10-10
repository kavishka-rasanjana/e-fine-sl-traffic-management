const mongoose = require('mongoose');

// Violation photos captured by the officer when issuing a fine.
// Kept in their own collection (linked by fineId) so fine lists stay small and fast.
// Images are compressed JPEGs stored as Base64 (survives server restarts on Render).
const fineEvidenceSchema = mongoose.Schema(
  {
    fineId: { type: mongoose.Schema.Types.ObjectId, ref: 'IssuedFine', required: true, unique: true },
    policeOfficerId: { type: String, required: true }, // Badge number of the issuing officer
    images: [{ type: String }], // data:image/jpeg;base64,...
    capturedAt: { type: Date, default: Date.now },
  },
  { timestamps: true }
);

module.exports = mongoose.model('FineEvidence', fineEvidenceSchema);
