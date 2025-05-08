const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");

router.post("/signup", authController.signup);
router.post("/login", authController.login);
router.post("/login-invite", authController.loginWithInvite);
router.post("/set-password", authController.setPassword);

module.exports = router;
