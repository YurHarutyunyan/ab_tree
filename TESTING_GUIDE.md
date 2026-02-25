# AB Tree Flutter - Complete Testing Guide

This guide walks you through testing all functionality of the app.

## Prerequisites

1. **Start the backend services**:
   ```bash
   ./start_app.sh
   ```

2. **Verify backend is running**:
   ```bash
   curl http://localhost:3000/health
   # Should return: {"success":true,"message":"AB Tree Backend API is running"...}
   ```

## Automated Backend API Test

Run the automated test script:

```bash
./test_complete_flow.sh
```

This will test all backend endpoints automatically.

---

## Manual Flutter App Testing

### Test 1: Registration Flow

**Steps:**
1. Launch the app: `flutter run --dart-define=DEVELOPMENT=true`
2. On the login screen, tap "Register" button
3. Fill in the registration form:
   - Username: `testuser1`
   - Email: `test1@example.com`
   - First Name: `Test`
   - Last Name: `User`
   - Password: `password123`
   - Confirm Password: `password123`
4. Tap "Register" button

**Expected Results:**
- ✅ Registration succeeds
- ✅ Automatically logs in
- ✅ Navigates to Apps Screen
- ✅ Shows 6 app cards

**Screenshot Checklist:**
- [ ] Registration form is visible
- [ ] All fields accept input
- [ ] Success message appears
- [ ] Apps screen loads

---

### Test 2: Login Flow

**Steps:**
1. If logged in, tap "My Account" → "Logout"
2. Enter credentials:
   - Username: `testuser1`
   - Password: `password123`
3. Tap "Login" button

**Expected Results:**
- ✅ Login succeeds
- ✅ Navigates to Apps Screen
- ✅ User session is maintained

**Screenshot Checklist:**
- [ ] Login form accepts credentials
- [ ] Error shown for wrong password
- [ ] Success redirects to apps

---

### Test 3: Apps Screen Navigation

**Steps:**
1. From Apps Screen, observe the layout
2. Verify all UI elements are present

**Expected Results:**
- ✅ Header shows "FREE APP" in orange on lighter blue background
- ✅ 6 app cards displayed in single column:
  - Art Lunch
  - Smart Portal
  - Business Hub
  - Learn Plus
  - Creative Studio
  - Finance Tracker
- ✅ Each card shows: logo, name, description, arrow icon
- ✅ Bottom has 3 buttons: "Presents", "My Account", "Support"

**Screenshot Checklist:**
- [ ] Header styling correct
- [ ] All 6 apps visible
- [ ] Cards are tappable
- [ ] Bottom buttons visible

---

### Test 4: App Detail Screen & Credits

**Steps:**
1. Tap on "Art Lunch" card
2. Observe the App Detail Screen
3. Note the credits count (should be **2**)
4. Tap the "BUY" button
5. Observe the credits count change
6. Tap "BUY" again
7. Try to tap "BUY" when credits = 0

**Expected Results:**
- ✅ Credits display: "Credits count: 2"
- ✅ After first BUY: Credits → 1
- ✅ Success snackbar shows: "Purchase successful! Credits remaining: 1"
- ✅ After second BUY: Credits → 0
- ✅ Button changes to "NO CREDITS"
- ✅ Tapping at 0 shows alert: "You have used all your credits"
- ✅ Alert has "Purchase Credits" button

**Screenshot Checklist:**
- [ ] Credits counter visible at top
- [ ] BUY button with blue border
- [ ] Credits decrement on tap
- [ ] Alert shows when 0 credits
- [ ] Back button works

---

### Test 5: Credits Persistence

**Steps:**
1. With "Art Lunch" at 0 credits, go back to Apps Screen
2. Tap "Smart Portal"
3. Observe credits (should be **2**)
4. Use 1 credit (tap BUY once)
5. Go back and open "Art Lunch" again
6. Verify it still shows 0 credits
7. Open "Smart Portal" again
8. Verify it shows 1 credit

**Expected Results:**
- ✅ Each app has independent credit count
- ✅ Credits persist when navigating between apps
- ✅ "Art Lunch": 0 credits
- ✅ "Smart Portal": 1 credit
- ✅ Other apps: 2 credits each

**Screenshot Checklist:**
- [ ] Different apps show different credit counts
- [ ] Credits don't reset on navigation

---

### Test 6: Credits After Logout/Login

**Steps:**
1. Note current credit counts (Art Lunch: 0, Smart Portal: 1)
2. Tap bottom "My Account" button
3. Tap "Logout"
4. Login again with same credentials
5. Open "Art Lunch" → Check credits
6. Open "Smart Portal" → Check credits

**Expected Results:**
- ✅ "Art Lunch": Still 0 credits
- ✅ "Smart Portal": Still 1 credit
- ✅ Credits persist after logout/login
- ✅ Data is stored in backend database

**Screenshot Checklist:**
- [ ] Logout successful
- [ ] Login restores session
- [ ] Credits match pre-logout values

---

### Test 7: My Account Screen

**Steps:**
1. Tap bottom "My Account" button
2. Observe profile information
3. Tap email field and change email to `updated@example.com`
4. Tap phone field and enter `+1234567890`
5. Tap "Save Changes" button
6. Go back and return to "My Account"
7. Verify email and phone are saved

**Expected Results:**
- ✅ Shows username (non-editable)
- ✅ Shows full name (non-editable)
- ✅ Email is editable
- ✅ Phone is editable
- ✅ "Save Changes" button works
- ✅ Success message appears
- ✅ Changes persist after navigation
- ✅ "Payment" and "Logout" buttons work

**Screenshot Checklist:**
- [ ] Profile fields display correctly
- [ ] Edit mode enables text fields
- [ ] Save button works
- [ ] Success snackbar appears

---

### Test 8: Support Screen

**Steps:**
1. From Apps Screen, tap "Support" button
2. Observe the support information
3. Tap the phone number
4. Tap the email address

**Expected Results:**
- ✅ Shows phone number: +1 (555) 123-4567
- ✅ Tapping phone opens phone dialer
- ✅ Shows email: support@abtree.com
- ✅ Tapping email copies to clipboard
- ✅ Alert shows: "Email copied to clipboard"
- ✅ Back button returns to Apps Screen

**Screenshot Checklist:**
- [ ] Support info displayed
- [ ] Phone tap works
- [ ] Email copy works
- [ ] Alert appears

---

### Test 9: Presents Button

**Steps:**
1. From Apps Screen, tap "Presents" button

**Expected Results:**
- ✅ Currently navigates to Apps Screen (placeholder)
- ✅ No errors occur

**Note:** This is a placeholder for future feature.

---

### Test 10: Payment Screen (Optional - requires Stripe keys)

**Steps:**
1. From "My Account", tap "Payment" button
2. Fill in payment form:
   - Amount: 100
   - Card Number: 4242 4242 4242 4242 (Stripe test card)
   - Expiry: 12/25
   - CVV: 123
   - Name: Test User
3. Tap "Process Payment"

**Expected Results:**
- ✅ Payment form displays
- ✅ Card validation works
- ✅ If Stripe keys configured: Real payment processing
- ✅ If no Stripe keys: Simulated payment
- ✅ Success dialog shows
- ✅ All app credits should become 5 (with real payment)

**Screenshot Checklist:**
- [ ] Payment form visible
- [ ] Card input validates
- [ ] Success/error handling works

---

## Test Database Verification

After testing the app, verify database state:

```bash
./view_db.sh
```

**Check:**
- ✅ User record exists with username `testuser1`
- ✅ User has `appCredits` field
- ✅ `appCredits` matches UI state:
  - `Art Lunch`: 0
  - `Smart Portal`: 1
  - Others: 2
- ✅ `isPaymentValid`: false (or true if payment completed)
- ✅ Email and phone fields match "My Account"

---

## Common Issues & Solutions

### Issue 1: "Network error"
**Solution:** 
```bash
# Check backend is running
curl http://localhost:3000/health

# If not, start it
cd backend && docker compose up -d
```

### Issue 2: "Authentication failed"
**Solution:**
- Clear app data and restart
- Re-login with correct credentials
- Check backend logs: `cd backend && docker compose logs`

### Issue 3: Credits not decreasing
**Solution:**
- Verify backend is accessible
- Check API calls in app logs
- Verify JWT token is valid

### Issue 4: Blank screen or crash
**Solution:**
```bash
# Full restart
flutter clean
flutter pub get
flutter run --dart-define=DEVELOPMENT=true
```

---

## Performance Checklist

Test app performance:
- [ ] App launches in < 3 seconds
- [ ] Login response < 1 second
- [ ] Navigation is smooth (60 FPS)
- [ ] Credits update immediately
- [ ] No memory leaks (check Flutter DevTools)
- [ ] Works on both Android and iOS

---

## Security Verification

Verify security measures:
- [ ] Passwords are not visible in logs
- [ ] JWT token is stored securely
- [ ] API requires authentication for protected routes
- [ ] Invalid tokens are rejected
- [ ] No database credentials in app code

---

## Test Summary Template

```
Test Date: ___________
Tester: ___________
Device: ___________
OS Version: ___________

✅ Registration: PASS / FAIL
✅ Login: PASS / FAIL  
✅ Apps Screen: PASS / FAIL
✅ Credits System: PASS / FAIL
✅ Credits Persistence: PASS / FAIL
✅ Profile Update: PASS / FAIL
✅ Support Screen: PASS / FAIL
✅ Logout/Login: PASS / FAIL

Issues Found:
1. ____________________
2. ____________________
3. ____________________

Notes:
_______________________
_______________________
```

---

## Next Steps

After testing:
1. ✅ Fix any issues found
2. ✅ Configure real Stripe keys for payment testing
3. ✅ Deploy backend to cloud server (see DEPLOYMENT.md)
4. ✅ Update `lib/config/environment.dart` with production URL
5. ✅ Build release version
6. ✅ Submit to App Store

---

**Need Help?**
- Check backend logs: `cd backend && docker compose logs -f`
- View database: `./view_db.sh`
- Test API: `./test_complete_flow.sh`
- Read: `DEPLOYMENT.md` for production setup
