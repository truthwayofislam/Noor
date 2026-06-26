# 🤖 Telegram Report Bot Setup Guide

## 📱 Report Issue System

User app se directly Telegram pe issue report kar sakte hain!

---

## 🚀 Setup Instructions

### Step 1: Create Telegram Bot

1. **Open Telegram** aur search karo: `@BotFather`

2. **Create new bot:**
   ```
   /newbot
   ```

3. **Bot name do:**
   ```
   Noor Issue Reporter
   ```

4. **Username do (unique):**
   ```
   noor_issue_bot
   ```

5. **Bot Token milega** (example):
   ```
   1234567890:ABCdefGHIjklMNOpqrSTUvwxYZ1234567
   ```
   ⚠️ Is token ko save kar lo!

---

### Step 2: Get Your Chat ID

1. **Apne bot ko start karo** (jo abhi banaya)

2. **Koi message send karo** bot ko (kuch bhi)

3. **Browser mein ye URL open karo:**
   ```
   https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates
   ```
   
   Replace `<YOUR_BOT_TOKEN>` with actual token

4. **Chat ID milega** JSON mein:
   ```json
   {
     "chat": {
       "id": 123456789,  ← Ye tumhara chat ID
       "first_name": "Your Name"
     }
   }
   ```

---

### Step 3: Backend Configuration

**File:** `backend/.env`

Add these lines:
```bash
TELEGRAM_REPORT_BOT=1234567890:ABCdefGHIjklMNOpqrSTUvwxYZ1234567
TELEGRAM_CHAT_ID=123456789
```

⚠️ **Important:** Replace with your actual values!

---

## 📋 How It Works

### User Side:
1. User opens app
2. Goes to **More → Report Issue**
3. Selects issue type:
   - 🐛 Bug Report
   - 💡 Feature Request
   - 💬 Feedback
   - ❓ Question
   - 📝 Other
4. Writes description
5. Clicks "Submit Report"

### You Receive:
```
🔔 New Issue Report #1234

👤 User Info:
   • Username: Abdullah123
   • Email: user@example.com

🏷️ Issue Type: Bug Report

📝 Description:
Prayer times not loading properly

📱 Device Info:
   • Platform: Android
   • OS Version: Android 12
   • Device: Samsung Galaxy S21

📲 App Version: 1.0.0

🕐 Timestamp: 2024-12-25 10:30:45

━━━━━━━━━━━━━━━━━━
```

---

## ✨ Features

### Auto-Included Info:
✅ User email (if logged in)
✅ Username (if logged in)
✅ Device platform (Android/iOS)
✅ OS version
✅ Device model
✅ App version
✅ Timestamp
✅ Unique issue number

### Issue Categories:
1. **Bug Report** 🐛 - App issues/crashes
2. **Feature Request** 💡 - New feature suggestions
3. **Feedback** 💬 - General feedback
4. **Question** ❓ - User queries
5. **Other** 📝 - Miscellaneous

---

## 🔒 Privacy & Security

- Bot token stored in backend (not in app)
- Only you receive reports
- User email optional
- Guest users can also report
- No sensitive data exposed

---

## 🧪 Testing

### Test the system:

1. **Start backend:**
   ```bash
   cd backend
   python main.py
   ```

2. **Run Flutter app:**
   ```bash
   flutter run
   ```

3. **Go to:** More → Report Issue

4. **Submit test report**

5. **Check Telegram** - message should appear!

---

## 🛠️ Troubleshooting

### Issue: Not receiving messages

**Check:**
1. ✅ Bot token correct?
2. ✅ Chat ID correct?
3. ✅ Bot started by you?
4. ✅ Backend running?
5. ✅ Internet connection?

**Test manually:**
```bash
curl -X POST "https://api.telegram.org/bot<BOT_TOKEN>/sendMessage" \
  -H "Content-Type: application/json" \
  -d '{"chat_id": "<CHAT_ID>", "text": "Test message"}'
```

### Issue: App shows error

**Possible causes:**
- Backend not running
- Wrong bot credentials
- No internet connection

**Solution:**
- Check backend logs
- Verify .env file
- Test API endpoint: `/telegram-config`

---

## 📊 Alternative: Email System

If Telegram doesn't work, you can use email:

**Change in:** `lib/services/telegram_report_service.dart`

Replace with email sending logic using packages like:
- `mailer`
- `flutter_email_sender`

---

## 🎯 Benefits

### For You:
- ✅ Instant notifications
- ✅ All info in one place
- ✅ Easy to track
- ✅ Can reply to users (optional)
- ✅ No extra app needed

### For Users:
- ✅ Easy to report
- ✅ Quick form
- ✅ No email client needed
- ✅ Anonymous option
- ✅ Professional system

---

## 📱 Screenshots

### User sees:
- Clean form
- Issue type chips
- Description field
- Submit button
- Success/error messages

### You receive:
- Formatted message
- All details
- Professional looking
- Easy to read

---

## 🔄 Future Enhancements

Possible additions:
- [ ] Screenshot attachment
- [ ] In-app reply system
- [ ] Issue status tracking
- [ ] Auto-responses
- [ ] Analytics dashboard
- [ ] Multiple admins

---

## 📞 Support

If you need help setting this up:
1. Check bot token is correct
2. Verify chat ID
3. Test API endpoint
4. Check backend logs

---

**Happy Bug Hunting! 🐛🔫**

بارک اللہ فیک
