# Auto-Discovery of New Repositories

## Overview

The CTS Agent Monitoring system **automatically discovers and monitors new repositories** without requiring any manual configuration.

## How It Works

### Discovery Process

The monitor scans the following directory structure:
```
/mnt/c/Users/be10cs1/github/
├── cain-git/
│   ├── ai-agent-architecture/
│   ├── cain-template/
│   └── openmetal-os-cloud/
├── cts-git/
│   ├── afghan-konar-valley-visualization/
│   ├── cts-code-metrics/
│   ├── cts-gis-portfolio/
│   └── colin-tda/
├── tda-git/
│   ├── tda-admin-management/
│   ├── ... (and 16 other TDA repos)
└── tt-git/
    ├── tt-chattanooga-crime/
    ├── tt-template/
    └── tt-tennessee-public-areas/
```

### Detection Logic

For each discovered directory:

1. **Is it a git repository?**
   - Check for `.git/` folder
   - Skip if not found

2. **Does it have Python code?**
   - Check for `requirements.txt` or `requirements-dev.txt`
   - Skip if neither found

3. **Is it already monitored?**
   - Check state tracking files
   - Skip if recently monitored

4. **Proceed with monitoring**
   - Install dependencies
   - Run code quality checks
   - Run security scans
   - Run dependency checks
   - Generate report

---

## Adding New Repositories

### Option 1: Clone into Existing Directory Structure (Automatic)

Simply clone a new repository into an existing folder structure:

```bash
# Example: Add a new TDA project
git clone https://github.com/tn-dept-ag/new-tda-project.git \
  /mnt/c/Users/be10cs1/github/tda-git/new-tda-project

# Next monitoring run will automatically discover it!
```

The monitor will:
- ✅ Discover the new repo on next run
- ✅ Run all checks
- ✅ Generate a health report
- ✅ Create PRs if fixes are needed

### Option 2: Create New Directory Structure (Automatic)

Create a new folder under `/mnt/c/Users/be10cs1/github/`:

```bash
# Add under existing group
git clone https://github.com/user/repo.git \
  /mnt/c/Users/be10cs1/github/cain-git/new-repo

# Or create a new group
mkdir -p /mnt/c/Users/be10cs1/github/new-group-git
git clone https://github.com/user/repo.git \
  /mnt/c/Users/be10cs1/github/new-group-git/new-repo
```

Both are automatically discovered on the next monitoring run.

---

## When New Repos Are Discovered

### First Monitoring Run After Addition

```
Monitor Starts
    ↓
Scans directory structure
    ↓
Discovers new repository
    ↓
    ├─ Clones/pulls latest code
    ├─ Installs dependencies (if Python project)
    ├─ Runs code quality checks (ruff)
    ├─ Runs security scans (bandit)
    ├─ Runs dependency checks (safety)
    ├─ Auto-applies fixable issues
    ├─ Creates PR with fixes (if needed)
    └─ Generates health report
    ↓
Result: New repo is now actively monitored
```

### Subsequent Runs

The repository is checked daily along with all other monitored repos.

---

## Configuration Changes for Auto-Discovery

You can customize discovery behavior in `~/.claude/health-monitor/config.conf`:

```bash
# Repositories to always monitor
ALWAYS_MONITOR="tda-git cain-git cts-git tt-git"

# Directories to scan for new repos
SCAN_PATHS="/mnt/c/Users/be10cs1/github/*/"

# Skip certain patterns
SKIP_PATTERNS="archive|backup|deprecated|test-*"
```

---

## Examples

### Example 1: Add a New TDA GIS Project

```bash
# Clone the new project
cd /mnt/c/Users/be10cs1/github/tda-git
git clone https://github.com/tn-dept-ag/new-gis-project.git

# Monitor will discover on next run
# You'll see a report in:
# ~/.claude/health-monitor/reports/new-gis-project_*.md
```

### Example 2: Add a Non-Python Project

```bash
# Clone a non-Python project
cd /mnt/c/Users/be10cs1/github/cts-git
git clone https://github.com/colinstiles/node-project.git

# Monitor will detect it's not Python
# It will be skipped (no requirements.txt/requirements-dev.txt)
# To enable: Add Python requirements or JavaScript tooling
```

### Example 3: Create a New Organization Group

```bash
# Create a new directory for a new GitHub organization
mkdir -p /mnt/c/Users/be10cs1/github/new-org-git

# Clone projects into it
git clone https://github.com/new-org/project1.git \
  /mnt/c/Users/be10cs1/github/new-org-git/project1

git clone https://github.com/new-org/project2.git \
  /mnt/c/Users/be10cs1/github/new-org-git/project2

# Monitor will auto-discover both on next run
```

---

## Monitoring Status

### See Which Repos Are Being Monitored

```bash
# View latest monitoring log
bash ~/.claude/health-monitor/view-logs.sh

# Check state tracking
ls -lh ~/.claude/health-monitor/state/

# View all reports
bash ~/.claude/health-monitor/view-reports.sh
```

### See What Repos Are Discovered But Skipped

```bash
# Grep logs for skip messages
grep "SKIP\|Not a Python" ~/.claude/health-monitor/logs/cron.log

# Or search all logs
grep -r "Not a Python" ~/.claude/health-monitor/logs/
```

---

## Removing Repositories from Monitoring

### Option 1: Delete the Repository

```bash
# Simply remove the directory
rm -rf /mnt/c/Users/be10cs1/github/cain-git/old-project

# Monitor will no longer discover it
```

### Option 2: Add to Skip List

Edit `~/.claude/health-monitor/config.conf`:

```bash
SKIP_PATTERNS="archive|backup|deprecated|old-project"
```

### Option 3: Clear State Tracking

If you want to re-monitor a repo that was previously skipped:

```bash
# Remove its state files
rm ~/.claude/health-monitor/state/repo-name.*

# Next run will re-discover and check it
```

---

## Frequently Asked Questions

### Q: Do I need to manually add each new repo?

**A:** No! The monitor automatically discovers any repo added to `/mnt/c/Users/be10cs1/github/`.

### Q: What if I add a non-Python repo?

**A:** It will be discovered but skipped (no Python requirements file). Add a Python requirements file or JavaScript/Node.js tooling to enable monitoring.

### Q: How often are new repos discovered?

**A:** On every monitoring run (daily at 2 AM UTC by default). You can change the schedule with `crontab -e`.

### Q: Can I exclude certain repos from monitoring?

**A:** Yes! Add them to the `SKIP_PATTERNS` in config.conf or simply don't create a requirements.txt file.

### Q: What if I rename a repo directory?

**A:** The monitor will treat it as a new repo on the next run. Old state files will become orphaned but won't affect anything.

### Q: Can I change the discovery path?

**A:** Yes, edit `SCAN_PATHS` in `~/.claude/health-monitor/config.conf` to scan different locations.

---

## Summary

- ✅ **Automatic discovery** - New repos are found automatically
- ✅ **No configuration needed** - Just clone into the right location
- ✅ **Real-time status** - Immediately available for monitoring
- ✅ **Easy removal** - Delete directory to stop monitoring
- ✅ **Flexible** - Skip patterns for selective monitoring

**Bottom line:** Add a new repo to `/mnt/c/Users/be10cs1/github/`, and it will be automatically monitored starting with the next daily monitoring run.
