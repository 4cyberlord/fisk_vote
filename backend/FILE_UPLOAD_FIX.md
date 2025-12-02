# File Upload Configuration Fix

## Issue
Image uploads were failing with error: "The data.photo_url.[uuid] failed to upload."

## Root Cause
PHP's default upload limits were set to 2MB, but the application allows uploads up to 10MB.

## Fixes Applied

### 1. Updated .htaccess (for Apache servers)
Added PHP configuration directives to `public/.htaccess`:
- `upload_max_filesize = 10M`
- `post_max_size = 12M` (slightly larger than upload_max_filesize)
- `max_execution_time = 300`
- `max_input_time = 300`

### 2. Created php.ini (for PHP-FPM or if .htaccess doesn't work)
Created `public/php.ini` with the same settings.

## Additional Server Configuration (if above doesn't work)

### For Apache with mod_php:
The `.htaccess` file should work automatically. Restart Apache if needed:
```bash
sudo service apache2 restart
# or
sudo systemctl restart apache2
```

### For PHP-FPM (Nginx):
Edit your PHP-FPM configuration file (usually `/etc/php/8.x/fpm/php.ini` or similar):
```ini
upload_max_filesize = 10M
post_max_size = 12M
max_execution_time = 300
max_input_time = 300
memory_limit = 256M
```

Then restart PHP-FPM:
```bash
sudo service php8.x-fpm restart
# or
sudo systemctl restart php8.x-fpm
```

### For Development (Laravel Sail/Docker):
If using Laravel Sail, edit `docker/php/local.ini` or create it:
```ini
upload_max_filesize = 10M
post_max_size = 12M
max_execution_time = 300
max_input_time = 300
memory_limit = 256M
```

Then rebuild the container:
```bash
./vendor/bin/sail build --no-cache
./vendor/bin/sail up -d
```

## Verification

After applying the fix, verify the settings:
```bash
php -i | grep -E "upload_max_filesize|post_max_size"
```

You should see:
- `upload_max_filesize => 10M`
- `post_max_size => 12M`

## Notes

- `post_max_size` should always be larger than `upload_max_filesize` (we set it to 12M)
- The `maxSize(10240)` in the Filament form is in KB (10240 KB = 10MB)
- If uploads still fail, check:
  1. Storage directory permissions: `storage/app/public/candidate-photos` should be writable (775)
  2. Storage link exists: `php artisan storage:link`
  3. Server error logs for more details

