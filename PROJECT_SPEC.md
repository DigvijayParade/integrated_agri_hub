# 🌾 Integrated Agri Hub — Project Specification
**Last Updated:** August 16, 2026  
**Version:** 2.0 — Post Architecture Discussion

---

## 📌 Project Overview
A multi-role agricultural app connecting **Farmers**, **Shopkeepers**, and **Government Admin**.  
Built with **Flutter** + **Firebase** (Auth, Firestore, Storage) + **Gemini AI**.

---

## 👥 Roles

| Role | Access |
|---|---|
| Farmer | Home, Market, Quiz, Education |
| Shopkeeper | Home, Inventory, Ledger, QR Scanner |
| Admin | Publish tasks, market data, education content |
| Super Admin | Backdoor login via `GOV-ADMIN` keyword |

---

## ✅ COMPLETED WORK

### Authentication
- [x] Real Firebase Email + Password signup (Farmer & Shopkeeper)
- [x] OTP section removed — email only
- [x] Login reads role from Firestore → routes to correct home screen
- [x] Admin backdoor: type `GOV-ADMIN` in email field → goes to Admin screen
- [x] Google Sign-In button → shows "Coming Soon" (not implemented yet)

### Firestore Data Structure
- [x] On farmer signup, saves:  
  `{ role, fullName, email, state, selectedCrops, greenCoins: 0, streak: 0, quizzesCompleted: 0, createdAt }`
- [x] On shopkeeper signup, saves:  
  `{ role, fullName, email, shopId, shopLicense, state, shopAddress, todaySales: 0, createdAt }`

### Farmer Home Screen
- [x] Loads real name + crops from Firestore on login
- [x] Green Coins starts at 0 (no dummy data)
- [x] Transactions list starts empty
- [x] Notifications start empty
- [x] Streak shows 0 Days
- [x] Quizzes Done shows 0
- [x] Tasks section shows "No tasks assigned yet" when empty

### Shopkeeper Home Screen
- [x] Loads real shop name from Firestore on login
- [x] Today's Sales starts at ₹0
- [x] Ledger starts empty
- [x] Inventory starts empty

### Code Quality
- [x] Removed all dummy/hardcoded profiles
- [x] Fixed `use_build_context_synchronously` lint
- [x] Fixed `prefer_typing_uninitialized_variables` lint
- [x] Removed unused `_farmerState` field
- [x] All changes pushed to GitHub (main + frontend branches)

---

## 🔄 IN PROGRESS / TODO

---

## 🌾 FARMER MODULE — Full Spec

### 1. Authentication & Profile
**Status:** ⏳ Partial — auth works, profile persistence needs work

**What needs to happen:**
- After login, load ALL user data from Firestore:
  - Full name, email, state, selected crops
  - Green coin balance
  - Current streak count
  - Last active date (for streak calculation)
  - Total quizzes completed
  - Total tasks completed
- Profile section must show this real data
- All changes (coins, streak) must save back to Firestore in real time

---

### 2. Home Tab — Tasks
**Status:** ❌ Not started

**How it works:**
- Admin publishes tasks in format: `{ crop, title, description, coinsReward, publishedDate }`
- Farmer sees ONLY tasks for crops they have selected during signup
- Tasks appear in farmer's Home screen under "Real-Life Tasks & Rewards"

**Task Completion Flow:**
1. Farmer taps "Mark as Done" → opens camera/gallery to upload proof photo
2. Photo sent to **Gemini Vision AI** with prompt:  
   *"Does this image show [task description]? Answer only Yes or No."*
3. If Gemini says **Yes** → task marked complete, coins credited to Firestore
4. If Gemini says **No** → show error: "Photo doesn't match the task. Try again."
5. Completed task disappears from pending list

**Daily Task Reward Rule:**
- Only **1 task rewarded per day** (coins-wise)
- If farmer completes 2 tasks in a day → only first one gives coins
- Second task is still marked complete (gone from pending) but no coins
- Pending tasks stay visible until completed — they don't expire

---

### 3. Market Tab
**Status:** ❌ Not started

**How it works:**
- Admin uploads a **CSV file** to Firebase Storage
- CSV columns: `Region, Crop, Price, Date`
  - Region = city/district within the farmer's selected state
- App reads CSV and displays as a filterable list/table

**Farmer Filters:**
- By **Crop** (dropdown)
- By **Region** (cities from their state only)
- By **Date** (date picker or range)

**Note:** Farmers only see regions from their own state (selected during signup)

---

### 4. Quiz Tab
**Status:** ⏳ Partial — UI exists, needs AI + Firestore integration

**How it works:**
- Gemini AI generates quiz questions based on farmer's selected crops
- Prompt format:  
  *"Generate 5 multiple-choice questions about [crop name] farming. Return as JSON array with fields: question, options (array of 4), correctIndex."*
- Questions shown one at a time with 4 options

**Reward Rules:**
- **100 coins** per quiz completion
- **Only 1 quiz rewarded per day** (regardless of which crop)
- If farmer attempts 2nd quiz same day → quiz is playable but shows "No reward for today"
- Track in Firestore: `lastQuizDate` field — compare with today's date

---

### 5. Education Tab
**Status:** ⏳ Partial — UI exists, needs admin content integration

**How it works:**
- Admin uploads education content per crop:
  - **Education cards** (text + image)
  - **YouTube video links**
- Farmer sees ONLY content for their selected crops
- Content is fetched from Firestore collection: `education/{cropName}/content`

---

### 6. Green Coins System
**Status:** ⏳ Partial — shown in UI, not saved to Firestore yet

**Earning Rules:**
| Activity | Coins |
|---|---|
| Daily login (first login of day) | +10 |
| Quiz completion (1st quiz of day) | +100 |
| Task completion (1st task of day) | Admin-set amount |
| 29-day streak bonus | +100 |

**Spending:**
- Coins spent at shopkeeper
- Farmer shows their **QR code** → shopkeeper scans → coins deducted from farmer's Firestore balance
- Transaction logged for both farmer and shopkeeper

**Firestore field:** `greenCoins` (integer, updated on every earn/spend)

---

### 7. Streak System
**Status:** ❌ Not started

**Rules:**
- Streak increments when farmer completes **at least 1 activity** (quiz OR task) in a day
- If farmer skips a day → streak resets to 0
- **29-day streak = 100 bonus coins** (auto-credited)
- Firestore fields needed: `streak` (int), `lastActiveDate` (string/timestamp)

**Logic:**
```
today = current date
lastActive = Firestore lastActiveDate
if today == lastActive + 1 day → streak++
if today == lastActive → no change (same day)
if today > lastActive + 1 day → streak = 0 (reset)
if streak == 29 → credit 100 coins, reset streak to 0
```

---

### 8. QR Code System
**Status:** ⏳ Partial — QR scanner exists, not connected to Firestore

**Farmer QR:** Contains their UID (Firestore document ID)  
**Shopkeeper scans:** Reads UID → looks up farmer in Firestore → deducts coins → logs transaction

---

## 🏪 SHOPKEEPER MODULE
*(Discussion deferred — will be planned separately)*

**Known so far:**
- Real inventory (starts empty, shopkeeper adds products)
- Real ledger entries (start empty, added via QR scan or manual entry)
- Today's sales = sum of ledger entries for today
- Can scan farmer QR to accept coin payment

---

## 🛠️ ADMIN MODULE
**Status:** ⏳ Basic UI exists — needs Firestore publishing

**Admin needs to be able to:**
- [ ] Publish tasks (select crop, write description, set coin reward)
- [ ] Upload market CSV file
- [ ] Upload education cards (text + image) per crop
- [ ] Add YouTube video links per crop

---

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) |
| Authentication | Firebase Auth (Email/Password) |
| Database | Cloud Firestore |
| File Storage | Firebase Storage (CSV, images) |
| AI — Quiz Generation | Gemini API (text) |
| AI — Photo Verification | Gemini Vision API (image) |
| QR Scanner | `mobile_scanner` package |

---

## 📁 Key Files

| File | Purpose |
|---|---|
| `lib/screens/welcome_screen.dart` | Login screen |
| `lib/screens/farmer_signup_screen.dart` | Farmer registration |
| `lib/screens/shopkeeper_signup_screen.dart` | Shopkeeper registration |
| `lib/screens/farmer_home_screen.dart` | Farmer dashboard (4 tabs) |
| `lib/screens/shopkeeper_home_screen.dart` | Shopkeeper dashboard |
| `lib/screens/admin_home_screen.dart` | Admin panel |
| `lib/services/firebase_auth_service.dart` | Auth + Firestore service |
| `lib/theme/app_theme.dart` | App colors and theme |

---

## 🗺️ Firestore Collections Structure

```
users/
  {uid}/
    role: "farmer" | "shopkeeper"
    fullName: string
    email: string
    state: string
    selectedCrops: [string]     ← farmer only
    greenCoins: number          ← farmer only
    streak: number              ← farmer only
    lastActiveDate: string      ← farmer only
    lastQuizDate: string        ← farmer only
    quizzesCompleted: number    ← farmer only
    shopId: string              ← shopkeeper only
    shopLicense: string         ← shopkeeper only
    shopAddress: string         ← shopkeeper only

tasks/
  {taskId}/
    crop: string
    title: string
    description: string
    coinsReward: number
    publishedDate: timestamp
    publishedBy: adminUid

market/
  {entryId}/
    region: string
    crop: string
    price: number
    date: timestamp
    uploadedBy: adminUid

education/
  {crop}/
    content/
      {contentId}/
        type: "card" | "video"
        title: string
        body: string             ← for card
        imageUrl: string         ← for card
        youtubeUrl: string       ← for video
        publishedDate: timestamp

transactions/
  {txId}/
    farmerUid: string
    shopkeeperUid: string
    coinsSpent: number
    date: timestamp
```

---

## 🚀 Implementation Order (Priority)

1. **Persistent profile data** — load all farmer data from Firestore on login
2. **Streak + daily login coins** — track `lastActiveDate`, credit 10 coins on first login
3. **Admin: Publish tasks** — admin creates tasks in Firestore
4. **Farmer: Tasks with AI photo verification** — Gemini Vision verifies photo
5. **Quiz: Gemini AI questions** — generate per crop, enforce 1/day limit
6. **Market: CSV upload + display** — admin uploads, farmer filters
7. **Education: Admin content** — cards + videos per crop
8. **QR coin spending** — farmer QR → shopkeeper scan → deduct coins
9. **Shopkeeper module** — full real data persistence

---

*This document is the single source of truth for the project. Update it as features are completed.*
