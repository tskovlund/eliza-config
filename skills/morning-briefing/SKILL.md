# Morning Briefing

Deliver a concise daily summary to Thomas via Telegram. Covers system health, project status, calendar, and anything that needs attention.

## When to use

- Scheduled: every day at 07:00 Europe/Berlin
- When Thomas asks "morning briefing", "what's happening", "daily summary"

## Steps

1. **System health** (run the system-health skill checks):
   - `df -h /` — disk usage
   - `free -h` — memory
   - `systemctl is-active zeroclaw caddy uptime-kuma grafana prometheus loki promtail ntfy-sh` — services
   - `systemctl --failed --no-pager` — any failures
   - `journalctl -p err --since '24 hours ago' --no-pager -q | tail -5` — recent errors

2. **Backup status**:
   - `systemctl status restic-backups-b2.timer --no-pager` — last run
   - Check if last backup succeeded via journal: `journalctl -u restic-backups-b2 --since '48 hours ago' --no-pager -q | tail -5`

3. **Linear status** (via HTTP API):
   - Issues In Progress for Thomas
   - Any issues moved to Blocked
   - New issues in Triage that need shaping
   - Use `http_request` to query Linear's GraphQL API

4. **GitHub activity** (via `gh`):
   - Open PRs across tskovlund repos
   - Any failed CI checks
   - `gh pr list --author tskovlund --state open`

5. **Weather** (optional, via web search):
   - Current conditions + forecast for Aarhus, Denmark

## Output format

Compact Telegram message. Lead with problems, then status, then info.

```
Morning briefing — [date]

[If problems exist:]
ISSUES:
- Disk at 85% — consider cleanup
- restic backup failed 2 days ago

MILES:
All services running. Disk 45%. Memory 1.2/4 GB.
Last backup: 6h ago.

LINEAR:
2 In Progress, 1 Blocked (TSK-45: waiting on gh CLI)
3 items in Triage

GITHUB:
1 open PR (nix-config #42 — CI passing)

WEATHER:
Aarhus: 4C, overcast. Rain expected afternoon.
```

## Cron setup

```
zeroclaw cron add morning-briefing --cron "0 7 * * *" --timezone "Europe/Berlin" --message "Run the morning briefing skill"
```

## Notes

- Keep it scannable — Thomas reads on phone via Telegram
- If everything is fine, say so briefly. Don't pad with filler.
- Flag anything that changed since yesterday
- If Linear API key isn't configured yet, skip that section and note it
