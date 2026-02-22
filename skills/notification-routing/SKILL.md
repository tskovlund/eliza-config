# Notification Routing

Decide what's worth notifying Thomas about, when, and how urgently.

## When to use

- Before sending any proactive notification to Thomas
- When deciding whether an event warrants interruption
- When choosing between notification channels and urgency levels

## Decision framework

### Notify immediately (interrupt)

- Service down (any critical service: zeroclaw, caddy, grafana)
- Backup failure
- Security alert (failed SSH attempts spike, unauthorized access)
- CI failure on main branch
- Deployment failure

### Notify soon (next check-in or morning briefing)

- Disk usage above 80%
- Memory pressure (swap in use)
- Stale Linear issues (blocked for >3 days)
- PR waiting for review >24h
- Non-critical service degradation

### Include in briefing only (don't interrupt)

- Routine status updates
- Completed scheduled tasks
- Memory housekeeping results
- Self-improvement findings
- Weather changes

### Don't notify (just log)

- Successful routine operations
- Internal bookkeeping
- Memory recalls with no new findings
- Failed web searches (retry silently)

## Notification channels

### Telegram (primary)
- Default channel for all notifications
- Use message formatting for readability:
  - Bold for headers and emphasis
  - Code blocks for commands and output
  - Keep messages under 4096 chars (Telegram limit)

### Pushover (escalation)
- For critical alerts that need phone push notification
- Use sparingly — Thomas trusts you to filter
- Sound/priority levels: -1 (silent), 0 (normal), 1 (high priority, bypass quiet hours)

### Ntfy (system alerts)
- Grafana alerts route through ntfy automatically
- Don't duplicate alerts that ntfy already handles

## Urgency guidelines

- **Time of day matters**: Don't send non-urgent notifications between 23:00-07:00 Europe/Berlin
- **Batch when possible**: If 3 things happened in the last hour, send one message with all 3
- **Context over data**: "Disk at 85%, was 70% yesterday" is better than just "Disk at 85%"
- **Action items first**: Lead with what Thomas needs to do, then background

## Notes

- Thomas values signal over noise — too many notifications erode trust
- When in doubt, include in the morning briefing rather than interrupting
- Track notification patterns during self-improvement reviews: are you notifying too much? Too little?
- Respect quiet hours unless it's genuinely critical
