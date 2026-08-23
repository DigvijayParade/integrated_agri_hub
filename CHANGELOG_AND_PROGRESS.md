# Integrated Agri Hub - Project Progress & Status

## What Has Been Completed 

### Phase 1: Foundation & Firebase Integration
- **UserService Created**: A singleton service (`lib/services/user_service.dart`) handling all user-related logic.
- **Firebase Auth & Firestore**: Connected to Firebase. Real-time updates fetch user data like name, email, registered crops, green coins, and streak.
- **Daily Login Bonus**: Implemented logic to automatically grant +10 Green Coins upon the first login of the day.
- **Streak System**: Logic built to update streaks upon activity (login, task, quiz) and grant a 100 coin bonus after a 29-day streak.

### Phase 2: Admin Task Management
- **Admin Tasks Tab**: Added a tab in the Admin dashboard to create, publish, and delete tasks for specific crops.
- **Real-Time Farmer Tasks**: The Farmer's home screen now successfully streams tasks directly from Firestore, dynamically filtering them to only show tasks relevant to the farmer's registered crops.

### Phase 3: AI & Camera Integration (Tasks)
- **Environment & Dependencies**: Added `flutter_dotenv` for secure API key loading, `google_generative_ai` for AI features, and `image_picker` for camera usage.
- **AiService (`lib/services/ai_service.dart`)**: Created a dedicated service to handle all Gemini AI interactions.
- **AI Task Verification Flow**:
  - The farmer can click **"Capture Proof"** on a task to take a photo using their device camera.
  - The image and the task description are sent to the Gemini AI Vision model.
  - Gemini verifies if the image matches the required task.
- **Task Rewards**: 
  - If approved, the task is marked completed in Firestore and disappears from the dashboard.
  - The farmer receives the coins specified by the admin.
  - **Rule enforced**: Farmers are limited to earning coins from a task only **1 time per day**.

---

## What Is Pending (Where to Resume)

### Phase 3.6: AI Quiz Generator
- **Status**: Completed.
- **Implementation**: `AiService` uses the `gemini-1.5-flash` model with a JSON-mode prompt to generate a 10-question multiple-choice quiz about farming best practices for a specific crop.
- **Rules & Logic**: 
  - Dynamic generation: Farmers see a "Generate AI Challenge" button for every crop they have registered.
  - Passing score: Farmers must score at least 50% to pass the quiz.
  - Rewards: Passing grants +100 Green Coins.
  - Limit: Restricted to earning the quiz reward only **1 time per day** to prevent abuse.

### Phase 3.7: UI & Validation Bug Fixes (Testing Feedback)
- **Status**: ✅ COMPLETED.
- Fixed email/password validators, hardcoded profiles (Rajesh Patil / Balaji Agri Store), quiz loading state, Gemini JSON parsing, url_launcher for video/audio.

### Phase 3.8: Round 2 Bug Fixes (Post-Review Testing)
- **Status**: 🔴 NOT STARTED — PRIORITY BEFORE NEXT REVIEW.
- **Bug List:**
  1. **[CRITICAL] Gemini API Model Error**: Quiz generation fails with error: `models/gemini-1.5-flash is not found for API version v1beta`. Model name needs to be updated to the correct currently supported model (e.g. `gemini-1.5-flash-latest` or `gemini-pro`).
  2. **[HIGH] Farmer Registration — District & Field Size Selection**: During signup, farmer cannot select their district or enter their field size. These fields must be added to the signup form AND saved to Firestore so they display correctly on the profile ID card.
  3. **[HIGH] Back Button After Login Goes to Registration**: After logging in, pressing the Android back button takes the user back to the registration/welcome screen. Navigation stack must be cleared on login so the farmer stays logged in until they explicitly tap "Logout".
  4. **[HIGH] Email Validation for Farmer & Shopkeeper**: Email format validation (RegExp) may not be working correctly on both signup screens. Must be re-verified and confirmed to block bad emails like `abc` or `test@`.
  5. **[MEDIUM] Shopkeeper — Green Coin Wallet Missing**: The shopkeeper profile has no Green Coin Wallet section. Since shopkeepers handle coin redemptions from farmers, they should see a running balance of coins received/processed.
  6. **[MEDIUM] Farmer Data Persistence After Logout/Login**: Verify that Firestore correctly saves and restores all farmer stats — green coins, streak, completed quizzes, tasks — when the farmer logs out and logs back in.
  7. **[FUTURE] Admin — Active Subsidies & Discounts Tab**: Admin should be able to publish active government subsidies and discounts. Farmers will see these on their dashboard. (New feature to be built in a later phase.)


### Phase 4: Market Tab & CSV Upload
- **Status**: Not Started.
- **Goal**: Allow Admin to upload a CSV file of crop market data to Firebase. Allow farmers to filter this real data by region, crop, and date.

### Phase 5: Education Tab
- **Status**: Not Started.
- **Goal**: Allow Admin to publish educational cards/videos. Allow farmers to filter this content by their crops.

### Phase 6: QR Code & Shopkeeper Module
- **Status**: Not Started.
- **Goal**: Connect the QR scanner to Firestore to allow farmers to spend coins. Deduct coins from the farmer and log the transaction in the real Shopkeeper inventory/ledger.
- **Goal**: Implement the real Shopkeeper dashboard (inventory, sales, etc.).

---

## How to Test What's Done
1. Open the `.env` file and replace `your_api_key_here` with your actual **Gemini API Key**.
2. Run `flutter run`.
3. Login as an Admin to create some tasks for a specific crop (e.g., Cotton).
4. Login as a Farmer, ensure you have "Cotton" in your profile, and try taking a photo for the task!
