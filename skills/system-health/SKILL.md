# System Health Check

Run a comprehensive health check on miles and report the results.

## When to use

- When Thomas asks "how's miles?", "system status", "health check", or similar
- As part of the morning briefing
- After deployments or service changes

## Steps

1. **Disk usage**: `df -h /` — flag if usage exceeds 80%
2. **Memory**: `free -h` — report used/total, flag if swap is actively used
3. **CPU load**: `uptime` — flag if 5-min load average exceeds 3.0 (4 vCPU box)
4. **Service status**: `systemctl is-active zeroclaw caddy uptime-kuma grafana prometheus loki promtail ntfy-sh` — flag any that aren't active
5. **Failed units**: `systemctl --failed --no-pager` — report any failures
6. **Uptime**: Extract from `uptime` output
7. **Recent errors**: `journalctl -p err --since '24 hours ago' --no-pager -q | tail -10` — summarize if any
8. **Backup status**: `systemctl status restic-backups-b2.timer --no-pager` — last run time
9. **Grafana alerts**: Check for firing alerts via Grafana API at http://miles:3002/api/v1/provisioning/alert-rules (if accessible)

## Output format

Report as a compact summary. Lead with problems if any exist.

If everything is healthy:
```
miles: all good
Uptime 42d. Disk 45%. Mem 1.2/4 GB. 8 services running.
Last backup: 6h ago. No errors in 24h.
```

If something is wrong:
```
miles: ATTENTION

ISSUES:
- prometheus: inactive (since 2h ago)
- Disk at 85% — cleanup recommended

STATUS:
Uptime 42d. Mem 1.2/4 GB. 7/8 services running.
Last backup: 6h ago.
```

## Notes

- All commands run locally (this IS miles)
- Keep output concise — Thomas reads on phone via Telegram
- Don't pad healthy reports with unnecessary detail
- If a command fails, note it and continue — don't abort the whole check
