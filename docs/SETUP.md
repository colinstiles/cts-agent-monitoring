# Setup & Installation Guide

## Quick Setup (5 minutes)

### Step 1: Clone This Repository

```bash
git clone https://github.com/colinstiles/cts-agent-monitoring.git
cd cts-agent-monitoring
```

### Step 2: Run Installation Script

```bash
bash bin/install.sh
```

This will:
- ✅ Create `~/.claude/health-monitor/` directory
- ✅ Install Python tools (ruff, bandit, safety)
- ✅ Copy monitoring scripts
- ✅ Set up cron job for daily 2 AM execution
- ✅ Create configuration files

### Step 3: Verify Installation

```bash
# Check cron job
crontab -l | grep health-monitor

# Run manual test
bash ~/.claude/health-monitor/run-monitor.sh

# View results
bash ~/.claude/health-monitor/view-logs.sh
```

That's it! The monitor is now active and will run every day at 2 AM UTC.

---

## Detailed Setup

### Prerequisites

**Required:**
- Python 3.11+
- git
- cron (macOS/Linux)

**Optional:**
- `gh` CLI (for GitHub integration)

### Installation Steps

#### 1. Clone Repository

```bash
# Clone to preferred location
git clone https://github.com/colinstiles/cts-agent-monitoring.git ~/projects/monitoring
cd ~/projects/monitoring
```

#### 2. Run Installer

```bash
bash bin/install.sh
```

**What it does:**
```
1. Checks Python, git installation
2. Creates ~/.claude/health-monitor/
3. Copies all scripts and configs
4. Installs Python tools:
   - ruff (code quality)
   - bandit (security)
   - safety (dependencies)
5. Creates cron job
6. Generates helper scripts
```

**Expected output:**
```
🔧 Installing CTS Agent Monitoring

Checking prerequisites...
✓ Prerequisites met

Setting up monitoring directory...
✓ Directory structure ready

Installing scripts...
✓ Scripts installed

Setting up configuration...
✓ Configuration file created

Installing Python monitoring tools...
✓ Python tools installed

Setting up cron schedule...
✓ Scheduled: Daily at 2:00 AM UTC

════════════════════════════════════════════════════════════════
✓ Installation Complete
════════════════════════════════════════════════════════════════
```

#### 3. Verify Installation

Check all components are in place:

```bash
# Verify directory structure
ls -lh ~/.claude/health-monitor/

# Expected output:
# config.conf
# health-monitor-controller.sh
# run-monitor.sh
# view-logs.sh
# view-reports.sh
# reset-state.sh
# logs/ (directory)
# reports/ (directory)
# state/ (directory)
```

Check cron job:
```bash
crontab -l

# Expected output includes:
# 0 2 * * * bash '/home/colinstiles/.claude/health-monitor/run-monitor.sh' 2>&1
```

Check Python tools:
```bash
which ruff bandit safety

# Should show paths for all three tools
```

---

## Configuration

### Basic Configuration

Edit `~/.claude/health-monitor/config.conf`:

```bash
# Monitoring schedule (2 AM daily)
SCHEDULE="0 2 * * *"

# Repository root
GITHUB_ROOT="/mnt/c/Users/be10cs1/github"

# Auto-fix enabled
AUTO_FIX_ENABLED="true"

# Create PRs for fixes
AUTO_CREATE_PR="true"

# Monitoring tools
ENABLE_RUFF="true"
ENABLE_BANDIT="true"
ENABLE_SAFETY="true"
```

### Advanced Configuration

**Email Notifications:**
```bash
NOTIFY_EMAIL="your-email@example.com"
```

**Slack Integration:**
```bash
SLACK_WEBHOOK="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

**Report Retention:**
```bash
# Keep reports for 60 days instead of 30
KEEP_REPORTS_DAYS="60"
```

**Skip Patterns:**
```bash
# Don't monitor certain repos
SKIP_PATTERNS="archive|deprecated|test-*"
```

---

## First Run

### Option 1: Wait for Cron (2 AM UTC)

The monitor will run automatically tomorrow at 2 AM UTC.

Check results:
```bash
bash ~/.claude/health-monitor/view-logs.sh
bash ~/.claude/health-monitor/view-reports.sh
```

### Option 2: Run Now

Execute the monitor immediately:

```bash
bash ~/.claude/health-monitor/run-monitor.sh
```

Watch progress:
```bash
tail -f ~/.claude/health-monitor/logs/cron.log
```

---

## Troubleshooting Installation

### Python Tools Not Installed

**Error:**
```
ruff: command not found
```

**Solution:**
```bash
pip install ruff bandit safety
```

### Cron Job Not Scheduling

**Verify crontab is available:**
```bash
which crontab
```

**If not available (Windows):**
- Use WSL (Windows Subsystem for Linux)
- Or install cron equivalent
- Run manually: `bash ~/.claude/health-monitor/run-monitor.sh`

**Manually add to crontab:**
```bash
crontab -e

# Add line:
# 0 2 * * * bash '/home/colinstiles/.claude/health-monitor/run-monitor.sh' 2>&1

# Save and exit (vi: ESC, :wq, Enter)
```

### Permission Denied

**Error:**
```
Permission denied: install.sh
```

**Solution:**
```bash
chmod +x bin/install.sh
bash bin/install.sh
```

### Directory Already Exists

**If `~/.claude/health-monitor/` already exists:**
- Installer will preserve existing configuration
- Scripts will be updated
- Safe to re-run installer

---

## Updating

### Update to Latest Version

```bash
# Go to monitoring repo directory
cd ~/projects/monitoring

# Pull latest changes
git pull origin main

# Re-run installer to update scripts
bash bin/install.sh
```

### Update Python Tools

```bash
pip install --upgrade ruff bandit safety
```

---

## Uninstalling

### Remove Monitoring

```bash
# Remove cron job
crontab -e
# (delete the health-monitor line)

# Remove directory (optional)
rm -rf ~/.claude/health-monitor/

# Uninstall Python tools (optional)
pip uninstall ruff bandit safety
```

---

## Post-Installation

### Next Steps

1. ✅ Installation complete
2. ⏳ Monitor will run at 2 AM UTC tomorrow
3. 📊 Check reports: `bash ~/.claude/health-monitor/view-logs.sh`
4. 🔄 Review auto-created PRs on GitHub
5. ⚙️ Customize config as needed

### Useful Commands

```bash
# View status
bash ~/.claude/health-monitor/view-logs.sh

# List reports
bash ~/.claude/health-monitor/view-reports.sh

# Run manually
bash ~/.claude/health-monitor/run-monitor.sh

# Reset state
bash ~/.claude/health-monitor/reset-state.sh

# Edit config
nano ~/.claude/health-monitor/config.conf

# Edit schedule
crontab -e
```

### Monitor Health

Check if monitoring is working:

```bash
# View recent activity
tail -20 ~/.claude/health-monitor/logs/cron.log

# List recent reports (should show today's or recent dates)
ls -lht ~/.claude/health-monitor/reports/ | head -10

# Check state files (shows last check time)
ls -lh ~/.claude/health-monitor/state/
```

---

## Support

For issues, see:
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- [AUTO-DISCOVERY.md](AUTO-DISCOVERY.md)
- Main [README.md](../README.md)

Or check the monitoring logs:
```bash
cat ~/.claude/health-monitor/logs/cron.log
```
