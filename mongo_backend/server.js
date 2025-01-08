const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');

const app = express();
const port = 3000;

// Middleware to parse JSON bodies
app.use(bodyParser.json());

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/test_coords', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

// Define a Schema for Coordinates
const coordsSchema = new mongoose.Schema({
  notes: String,
  lat: Number,
  lng: Number,
  created_at: { type: Date, default: Date.now },
  updated_at: { type: Date, default: Date.now }
});

const Coord = mongoose.model('Coord', coordsSchema);

// Save coordinates endpoint
app.post('/coords', (req, res) => {
  const { notes, lat, lng } = req.body;
  const newCoord = new Coord({
    notes,
    lat,
    lng
  });

  newCoord.save()
    .then(coord => res.status(200).json(coord))
    .catch(err => res.status(400).json({ error: err.message }));
});

// Start the server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
}); 