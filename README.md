# virtualmin-healthcheck-laravel

## 💡 Background

In a Virtualmin-powered Laravel hosting environment, we experienced repeated issues where certain domains would stop responding after running smoothly for several days. The root cause was often due to `php8.1-fpm` processes becoming unresponsive or reaching system resource limits (e.g. `pm.max_children` or memory exhaustion), especially when multiple virtual hosts were running concurrently.

Since these failures didn't crash Apache or the entire server, traditional monitoring tools missed them. However, the Laravel apps would hang, causing frontend users to see infinite loading spinners or receive 5xx errors.

To solve this, we developed a simple bash-based health check system that:
- Periodically pings each domain’s `/health` endpoint
- Automatically restarts `php8.1-fpm` if failure conditions persist
- Writes logs per domain for easy diagnostics

This lightweight solution provides reliable self-recovery without needing third-party monitoring or complex infrastructure.

This project provides bash scripts for performing health checks on Laravel applications hosted on Virtualmin-based servers. The scripts monitor the availability of each domain’s `/health` endpoint and restart `php8.1-fpm` automatically if repeated failures are detected.

## 🔧 Features

- Health check for single and multiple Laravel domains
- Automatic PHP-FPM restart if application is unresponsive
- Simple log tracking per domain
- Configurable failure thresholds

## 📦 Requirements

To use this health check system, ensure your environment has the following:

- Bash shell (default on most Linux systems)
- `curl` for making HTTP requests
- `systemctl` to control services (e.g. restarting php8.1-fpm)
- Laravel route `/health` accessible without authentication

### Example `/health` Route
```php
Route::get('/health', function () {
    return response()->json(['status' => 'ok'], 200);
});
```

## 📁 Script Examples

### Single Domain

`/usr/local/bin/healthcheck-single-domain.sh`

### Multiple Domains

`/usr/local/bin/healthcheck-multiple-domains.sh`

### 🛡️ File Permission Setup

After creating a health check script, make sure it is executable:

```bash
sudo chmod +x /usr/local/bin/healthcheck-single-domain.sh
sudo chmod +x /usr/local/bin/healthcheck-multiple-domains.sh
```

## 🕑 Cron Setup

To run the script every minute, add to crontab:

```bash
sudo crontab -e
* * * * * /usr/local/bin/healthcheck-single-domain.sh
```

## 📄 Log Example

```bash
tail -f /var/log/healthcheck-abcprintf.com.log
```