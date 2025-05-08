const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const users = require("../data/users");

let userIdCounter = users.length + 1;
const SECRET_KEY = "your-secret-key";
const FORBIDDEN_ROLES = ["admin", "executive_admin", "founder_admin"];

const generateToken = (id, role, rememberMe = false) => {
  return jwt.sign({ id, role }, SECRET_KEY, {
    expiresIn: rememberMe ? "7d" : "1h",
  });
};

// 🔹 Signup — for buyers and invited sellers
const signup = async (req, res) => {
  try {
    const {
      name,
      email,
      phone,
      role,
      password,
      invitationCode,
      sellerLocation,
    } = req.body;

    if (!email && !phone) {
      return res.status(400).json({ error: "Email or phone is required." });
    }
    if (!password || !name || !role) {
      return res.status(400).json({ error: "All fields are required." });
    }

    if (FORBIDDEN_ROLES.includes(role)) {
      return res
        .status(403)
        .json({ error: "This role is not allowed for signup." });
    }
    if (role !== "buyer") {
      return res
        .status(403)
        .json({ error: "Only buyers can sign up directly." });
    }

    const existing = users.find((u) => u.email === email || u.phone === phone);
    if (existing) {
      return res.status(400).json({ error: "User already exists." });
    }

    let invited_by = null;

    // 🔹 Validate seller invite
    // if (role === "seller") {
    //   if (!invitationCode) {
    //     return res.status(403).json({ error: "Invitation code is required for seller role." });
    //   }

    //   const inviter = users.find(
    //     (u) => u.invitation_code === invitationCode && ["founder_admin", "executive_admin"].includes(u.role)
    //   );

    //   if (!inviter) {
    //     return res.status(403).json({ error: "Invalid invitation code." });
    //   }

    //   if (!sellerLocation) {
    //     return res.status(400).json({ error: "Seller must have a location." });
    //   }

    //   invited_by = inviter.id;
    // }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = {
      id: userIdCounter++,
      name,
      email: email || null,
      phone: phone || null,
      password: hashedPassword,
      role,
      //   invited: role === "seller",
      //   invitation_status: role === "seller" ? "Accepted" : "N/A",
      //   invitation_code: invitationCode || null,
      //   invited_by: invited_by || null,
      //   seller_location: role === "seller" ? sellerLocation : null,
      //   seller_category: role === "seller" ? [] : undefined,
      //   points: role === "buyer" ? 0 : undefined,
      createdAt: new Date(),
    };

    users.push(user);
    res.status(201).json({ message: "User registered successfully!" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error. Please try again later." });
  }
};

// 🔹 Login — by email or phone
const login = async (req, res) => {
  try {
    let { email, phone, password, rememberMe } = req.body;

    if (!email && !phone) {
      return res.status(400).json({ error: "Email or phone is required." });
    }

    email = email?.toLowerCase();

    const user = users.find(
      (u) => (email && u.email === email) || (phone && u.phone === phone)
    );

    if (!user) return res.status(404).json({ error: "User not found." });

    if (user.role === "seller" && user.invitation_status === "Pending") {
      return res
        .status(403)
        .json({ error: "Seller invitation is still pending." });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch)
      return res.status(400).json({ error: "Invalid credentials." });

    const token = generateToken(user.id, user.role, rememberMe);

    res.status(200).json({
      message: "Login successful!",
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        points: user.points,
        seller_category: user.seller_category || [],
        invited: user.invited,
        invitation_status: user.invitation_status,
        seller_location: user.seller_location || null,
        createdAt: user.createdAt,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error." });
  }
};

// 🔹 Login with invitation
const loginWithInvite = async (req, res) => {
  try {
    const { email, invitationCode } = req.body;

    const user = users.find((u) => u.email === email);

    if (!user || user.invitation_code !== invitationCode) {
      return res.status(400).json({ error: "Invalid invitation code." });
    }

    user.invitation_status = "Accepted";
    user.invitation_code = null;

    const token = generateToken(user.id, user.role, true);

    res.json({
      message: "Login successful!",
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        invitation_status: user.invitation_status,
        invited_by: user.invited_by,
        createdAt: user.createdAt,
      },
    });
  } catch (error) {
    console.error("Error logging in with invite:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// 🔹 Set password for invited user
const setPassword = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res
        .status(400)
        .json({ error: "Email and password are required." });
    }

    const user = users.find((u) => u.email === email);
    if (!user) {
      return res.status(404).json({ error: "User not found." });
    }

    user.password = await bcrypt.hash(password, 10);
    user.invitation_status = "Accepted";

    res.json({ message: "Password set successfully!" });
  } catch (error) {
    console.error("Error setting password:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

module.exports = {
  signup,
  login,
  loginWithInvite,
  setPassword,
};
