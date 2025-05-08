const express = require("express");
const jwt = require("jsonwebtoken");

const app = express();
const authRoutes = require("./routes/authRoutes");
const PORT = process.env.PORT || 5000;
// middleware
app.use(express.json());
// Routes
app.use("/api/auth", authRoutes);
app.get("/", (req, res) => {
  res.send("🚀  Welcome to bug server!");
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`connected at ${PORT}`);
});
