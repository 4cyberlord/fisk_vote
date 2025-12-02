# Laravel Queue Setup Guide

This application uses Laravel's queue system to send emails asynchronously, following industry best practices. This ensures better performance and user experience.

## Queue Configuration

The application is configured to use the **database** queue driver by default. This is set in `config/queue.php`:

```php
'default' => env('QUEUE_CONNECTION', 'database'),
```

## Required Database Tables

The following tables are required for the queue system:

1. **`jobs`** - Stores queued jobs waiting to be processed
2. **`job_batches`** - Stores batch information for grouped jobs
3. **`failed_jobs`** - Stores jobs that have failed after all retry attempts

These tables are created automatically when you run migrations.

## Running the Queue Worker

To process queued emails, you need to run a queue worker. Here are the recommended methods:

### Development (Local)

For local development, run the queue worker in a terminal:

```bash
cd backend
php artisan queue:work database --queue=emails
```

This will process jobs from the `emails` queue using the `database` connection. Press `Ctrl+C` to stop the worker.

**Recommended for development:**
```bash
php artisan queue:work database --queue=emails --tries=3 --timeout=120
```

**Note:** The `VerifyStudentEmail` notification is configured to use the `emails` queue, so make sure to specify `--queue=emails` when running the worker.

### Production (Server)

For production, you should run the queue worker as a background process using a process manager like **Supervisor** or **systemd**.

#### Option 1: Using Supervisor (Recommended)

1. Install Supervisor:
```bash
sudo apt-get install supervisor  # Ubuntu/Debian
# or
sudo yum install supervisor      # CentOS/RHEL
```

2. Create a Supervisor configuration file at `/etc/supervisor/conf.d/laravel-worker.conf`:

```ini
[program:laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /path/to/your/backend/artisan queue:work database --queue=emails --sleep=3 --tries=3 --timeout=120 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/path/to/your/backend/storage/logs/worker.log
stopwaitsecs=3600
```

**Important:** Replace `/path/to/your/backend` with your actual backend directory path.

3. Update Supervisor and start the worker:
```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start laravel-worker:*
```

4. Check status:
```bash
sudo supervisorctl status
```

#### Option 2: Using systemd (Linux)

1. Create a systemd service file at `/etc/systemd/system/laravel-worker.service`:

```ini
[Unit]
Description=Laravel Queue Worker
After=network.target

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /path/to/your/backend/artisan queue:work database --sleep=3 --tries=3 --max-time=3600

[Install]
WantedBy=multi-user.target
```

2. Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable laravel-worker
sudo systemctl start laravel-worker
```

3. Check status:
```bash
sudo systemctl status laravel-worker
```

#### Option 3: Using nohup (Simple Background Process)

For a quick solution without a process manager:

```bash
nohup php artisan queue:work --tries=3 --timeout=60 > storage/logs/queue.log 2>&1 &
```

## Queue Worker Options

Here are useful options for the `queue:work` command:

| Option | Description | Example |
|--------|-------------|---------|
| `--tries` | Maximum number of attempts for a job | `--tries=3` |
| `--timeout` | Maximum seconds a job can run | `--timeout=60` |
| `--sleep` | Seconds to wait when no jobs available | `--sleep=3` |
| `--max-time` | Maximum seconds the worker should run | `--max-time=3600` |
| `--queue` | Process a specific queue | `--queue=emails` |
| `--once` | Process only one job | `--once` |
| `--stop-when-empty` | Stop when queue is empty | `--stop-when-empty` |

## Monitoring Queue Jobs

### View Pending Jobs

Check the `jobs` table in your database:
```sql
SELECT * FROM jobs ORDER BY created_at DESC;
```

### View Failed Jobs

Check the `failed_jobs` table:
```sql
SELECT * FROM failed_jobs ORDER BY failed_at DESC;
```

Or use Artisan commands:
```bash
# List failed jobs
php artisan queue:failed

# Retry a specific failed job
php artisan queue:retry {job-id}

# Retry all failed jobs
php artisan queue:retry all

# Delete a failed job
php artisan queue:forget {job-id}

# Delete all failed jobs
php artisan queue:flush
```

## Testing the Queue

### Test Email Queue Locally

1. Start the queue worker:
```bash
php artisan queue:work
```

2. Register a new student account through the student panel

3. Check the queue worker terminal - you should see the email job being processed

4. Check your email inbox (or Mailtrap if configured)

### Check Queue Status

```bash
# See how many jobs are pending
php artisan queue:monitor database:default

# Check queue size
php artisan queue:size
```

## Troubleshooting

### Emails Not Sending

1. **Check if queue worker is running:**
   ```bash
   ps aux | grep "queue:work"
   ```

2. **Check for failed jobs:**
   ```bash
   php artisan queue:failed
   ```

3. **Check application logs:**
   ```bash
   tail -f storage/logs/laravel.log
   ```

4. **Verify email configuration:**
   - Check Email Settings in admin panel
   - Verify SMTP/Mailtrap credentials
   - Test email sending manually

### Queue Worker Keeps Stopping

1. **Check Supervisor/systemd logs:**
   ```bash
   sudo supervisorctl tail -f laravel-worker:*
   # or
   sudo journalctl -u laravel-worker -f
   ```

2. **Increase timeout if jobs are taking too long:**
   ```bash
   php artisan queue:work --timeout=120
   ```

3. **Check memory limits:**
   - Increase PHP memory limit in `php.ini`
   - Use `--max-time` to restart worker periodically

### Jobs Stuck in Queue

1. **Restart the queue worker:**
   ```bash
   php artisan queue:restart
   ```

2. **Clear stuck jobs (use with caution):**
   ```sql
   DELETE FROM jobs WHERE reserved_at < UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 1 HOUR));
   ```

## Best Practices

1. **Always run queue workers in production** - Emails won't send without a worker running
2. **Use Supervisor or systemd** - Ensures the worker restarts automatically if it crashes
3. **Monitor failed jobs** - Set up alerts for failed email jobs
4. **Set appropriate retry limits** - The notification is configured with 3 retries
5. **Use separate queues for different priorities** - You can create `high`, `default`, `low` queues
6. **Monitor queue size** - Alert if queue grows too large
7. **Regular cleanup** - Periodically clean up old failed jobs

## Environment Variables

Make sure your `.env` file has:

```env
QUEUE_CONNECTION=database
```

For other queue drivers (Redis, SQS, etc.), change this value and configure the corresponding connection in `config/queue.php`.

## Additional Resources

- [Laravel Queue Documentation](https://laravel.com/docs/queues)
- [Mailtrap Laravel Queue Guide](https://mailtrap.io/blog/laravel-mail-queue/)
- [Supervisor Documentation](http://supervisord.org/)

