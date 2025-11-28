const admin = require("firebase-admin");
require("dotenv").config();

let serviceAccount;

// লজিক: যদি সার্ভারে থাকি (ENV ভেরিয়েবল থাকে), সেটা ব্যবহার করো
// আর যদি লোকালে থাকি, তবে ফাইল ব্যবহার করো
if (process.env.GOOGLE_CREDENTIALS) {
  try {
    serviceAccount = JSON.parse(process.env.GOOGLE_CREDENTIALS);
  } catch (err) {
    console.error("Failed to parse GOOGLE_CREDENTIALS:", err);
  }
} else {
  // লোকাল ডেভেলপমেন্টের জন্য
  serviceAccount = require("../../serviceAccountKey.json");
}

if (serviceAccount) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
} else {
  console.error("❌ Firebase credential not found!");
}

module.exports = admin;