# Integrated Agri Hub 🌱

A comprehensive, multi-platform Flutter application designed to bridge the gap between Farmers, Shopkeepers, and Agricultural Administrators. 

This platform uses modern mobile technology, **Firebase** backend services, and **Google Gemini AI** to incentivize agricultural learning, track real-time market prices, and manage reward-based digital ledgers.

---

## 🌟 Core Features

### 🚜 For Farmers
- **Daily Tasks & Photo Verification**: Farmers can upload photos of their crop progress. The app uses **Gemini AI Vision** to instantly verify the photos and award digital coins.
- **AI-Generated Crop Quizzes**: Farmers can take dynamic, daily quizzes generated in real-time by **Gemini AI** based on their registered crops. Passing quizzes earns bonus coins.
- **Live Market Rates**: Stream live Mandi (market) prices for various crops directly from the government/admin database.
- **Reward Wallet & QR Codes**: Earned coins are stored in a digital wallet. Farmers can generate dynamic QR codes to spend these coins at local partner shops.

### 🏪 For Shopkeepers
- **QR Code Scanner**: Shopkeepers can scan the Farmer's reward QR codes using the built-in camera scanner.
- **Digital Ledger**: Instantly deduct coins from the farmer's wallet in exchange for agricultural supplies (seeds, fertilizers, tools).
- **Transaction History**: Maintain a transparent digital ledger of all sales and redeemed vouchers.

### 🏢 For Administrators
- **Market Price Management**: Admins can upload bulk CSV files containing the latest Mandi prices, which instantly syncs to all Farmer apps via Firestore.
- **Task Publishing**: Create new daily tasks and educational content for farmers across different regions and crop types.
- **Secure Access**: Dedicated admin portal accessible via secure backdoor login (`GOV-ADMIN`).

---

## 🛠️ Technology Stack

* **Frontend:** Flutter & Dart
* **Backend:** Firebase (Authentication, Cloud Firestore)
* **AI Integration:** Google Generative AI (`google_generative_ai` package)
* **Hardware APIs:** `image_picker` (Camera for tasks), `mobile_scanner` (QR scanning)
* **State Management:** Flutter `ChangeNotifier` and `StreamBuilder` for real-time UI updates.

---

## 🚀 Getting Started

### Prerequisites
1. **Flutter SDK** (v3.12.2 or higher)
2. A **Firebase Project** with Authentication (Email/Password) and Firestore enabled.
3. A **Google Gemini API Key**.

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/integrated_agri_hub.git
   ```
2. **Install Dependencies**
   ```bash
   flutter pub get
   ```
3. **Set up Environment Variables**
   Create a `.env` file in the root directory and add your Gemini API key:
   ```env
   GEMINI_API_KEY=your_api_key_here
   ```
4. **Run the App**
   ```bash
   flutter run
   ```

---

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! 
