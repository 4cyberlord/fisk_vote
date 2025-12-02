# Email Troubleshooting Guide

## Current Status

Based on the diagnosis:
- ✅ Queue worker is running
- ✅ Email settings are configured (Mailtrap)
- ✅ Mailtrap API key is set
- ⚠️  Mailtrap Sandbox is **DISABLED** (using production mode)
- ⚠️  No pending jobs in queue (jobs are being processed)
- ⚠️  No failed jobs (but emails aren't being received)

## Issue: Emails Not Being Received

### Problem 1: Mailtrap Production Mode

Your Mailtrap is configured for **production mode** (sandbox disabled). Production Mailtrap requires:
1. **Domain verification** - Your sending domain must be verified in Mailtrap
2. **Verified from email** - The "from" email must be from a verified domain
3. **Production API token** - Must use a production API token (not sandbox token)

### Solution Options:

#### Option A: Enable Sandbox Mode (Recommended for Testing)

1. Go to Admin Panel → System → Email & Notification Settings
2. Enable "Use Mailtrap Sandbox"
3. Enter your Mailtrap Inbox ID
4. Save settings
5. Test registration again

#### Option B: Configure Production Mailtrap Properly

1. Verify your domain in Mailtrap:
   - Go to Mailtrap dashboard
   - Navigate to Sending Domains
   - Add and verify your domain (e.g., `ctarlabs.com` or `fisk.edu`)
   - Add required DNS records (SPF, DKIM, DMARC)

2. Ensure "from" email is from verified domain:
   - Current: `no-reply@ctarlabs.com`
   - Must match a verified domain in Mailtrap

3. Use production API token:
   - Get token from: https://mailtrap.io/api-tokens
   - Make sure it's a **production** token (not sandbox)

### Problem 2: Check Email Logs

Run this command to see detailed email logs:
```bash
cd backend
tail -f storage/logs/laravel.log | grep -i "CustomMailChannel\|Mailtrap\|email"
```

Look for:
- `CustomMailChannel: Email sent successfully` - Email was sent
- `Mailtrap API Error` - There was an error sending
- `Mailtrap email sent successfully` - Confirmation of successful send

### Problem 3: Verify Queue Worker is Processing

The queue worker is running, but verify it's processing jobs:

```bash
# Watch the queue worker output
# You should see jobs being processed in real-time
```

If you see errors in the queue worker output, those are the actual issues.

### Problem 4: Check Mailtrap Dashboard

1. Go to your Mailtrap dashboard
2. Check the **Sandbox** inbox (if sandbox mode is enabled)
3. Or check **Sent** emails (if production mode)
4. See if emails are arriving there

## Quick Fix: Enable Sandbox Mode

**This is the easiest solution for testing:**

1. Go to: Admin Panel → System → Email & Notification Settings
2. Check "Use Mailtrap Sandbox"
3. Enter your Mailtrap Inbox ID (found in Mailtrap dashboard)
4. Save
5. Register a new student account
6. Check your Mailtrap Sandbox inbox for the email

## Diagnostic Commands

```bash
# Check email system status
php artisan email:diagnose

# Check queue status
php artisan queue:monitor database:emails

# Check failed jobs
php artisan queue:failed

# Process one job manually (for testing)
php artisan queue:work database --queue=emails --once

# View recent logs
tail -100 storage/logs/laravel.log | grep -i email
```

## Common Issues

### Issue: "Mailtrap API Error (HTTP 401)"
**Cause:** Invalid API key or wrong token type
**Solution:** 
- Verify API key in Email Settings
- Make sure you're using the correct token (sandbox vs production)

### Issue: "Mailtrap API Error (HTTP 422)"
**Cause:** Invalid email format or unverified domain
**Solution:**
- Check email addresses are valid
- For production: verify domain in Mailtrap
- For sandbox: ensure inbox ID is correct

### Issue: Emails Queued But Not Sent
**Cause:** Queue worker not running or jobs failing silently
**Solution:**
- Ensure queue worker is running: `ps aux | grep queue:work`
- Check failed jobs: `php artisan queue:failed`
- Check logs for errors

### Issue: Notification Not Showing on Login Page
**Cause:** Session/redirect issue
**Solution:**
- Clear browser cache
- Check browser console for JavaScript errors
- Verify session is working

## Next Steps

1. **Enable Mailtrap Sandbox** (easiest for testing)
2. **Check Mailtrap dashboard** for received emails
3. **Review logs** for any errors
4. **Test with a new registration**

If emails still don't work after enabling sandbox mode, check the logs for specific error messages.

