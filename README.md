# CTS Agent Monitoring

**Persistent automated health monitoring for all repositories**

Automated daily health checks across all 28 repositories in your GitHub portfolio. Monitors code quality, security, and dependencies—then auto-fixes issues and creates pull requests.

[![Status](https://img.shields.io/badge/Status-Active-success.svg)](README.md)
[![Schedule](https://img.shields.io/badge/Schedule-Daily%202AM%20UTC-blue.svg)](README.md)
[![Repos](https://img.shields.io/badge/Repos-28-orange.svg)](README.md)

---

## Overview

This repository contains the **persistent monitoring infrastructure** that automatically monitors all your repositories for:

- ✅ **Code Quality** - Python style violations, complexity, imports
- ✅ **Security** - Hardcoded secrets, SQL injection, unsafe patterns  
- ✅ **Dependencies** - Outdated packages, known CVEs, conflicts
- ✅ **Auto-fixes** - Formatting, imports, whitespace corrections
- ✅ **PR Creation** - Automatic pull requests with improvements
- ✅ **Health Reports** - Detailed metrics for each repository

**Frequency:** Daily at 2:00 AM UTC (configurable)  
**Repositories Monitored:** 28 (auto-discovered)  
**Status:** ✅ Active and Deployed

---

## Quick Start

### View Status
```bash
# See recent monitoring activity
bash ~/.claude/health-monitor/view-logs.sh

# List all health reports
bash ~/.claude/health-monitor/view-reports.sh

# View specific repository report
cat ~/.claude/health-monitor/reports/repo-name_*.md
```

### Run Manual Check
```bash
# Execute monitoring now (anytime)
bash ~/.claude/health-monitor/run-monitor.sh

# Watch output in real-time
tail -f ~/.claude/health-monitor/logs/cron.log
```

### Customize Schedule
```bash
# Edit cron schedule
crontab -e

# Common schedules:
# 0 2 * * *     = Daily at 2:00 AM (current)
# */4 * * * *   = Every 4 hours
# 0 0 * * *     = Daily at midnight
# 0 0 * * 0     = Weekly on Sunday
```

---

## Installation

The monitoring system is already deployed to your local machine:

**Location:** `~/.claude/health-monitor/`

**Components:**
- `health-monitor-controller.sh` - Main monitoring engine
- `run-monitor.sh` - Cron wrapper
- `view-logs.sh` - View activity
- `view-reports.sh` - List reports
- `config.conf` - Configuration
- `logs/` - Execution logs
- `reports/` - Health reports
- `state/` - Check tracking

To reinstall or update:
```bash
# Download this repository
git clone https://github.com/colinstiles/cts-agent-monitoring.git

# Run setup
bash cts-agent-monitoring/install.sh
```

---

## How It Works

### Daily Automated Workflow

Every day at 2:00 AM UTC:

```
Monitor Starts
    ↓
Discovers all 28 repositories
    ↓
For Each Repository:
  1. Pull latest code
  2. Run code quality checks (ruff)
  3. Run security scans (bandit)
  4. Check dependencies (safety)
  5. Auto-apply style fixes
  6. Create PR with improvements
  7. Generate health report
    ↓
Results Saved:
  • Reports: ~/.claude/health-monitor/reports/
  • Logs: ~/.claude/health-monitor/logs/
  • PRs: GitHub (chore/auto-health-check-*)
```

### Monitoring Scope

For each repository:

| Check | Tool | Detects |
|-------|------|---------|
| **Code Quality** | ruff | Style violations, complexity, imports |
| **Security** | bandit | Secrets, SQL injection, unsafe patterns |
| **Dependencies** | safety | Outdated packages, known CVEs |

### Auto-Fixes Applied

When issues are found:
- ✅ Code formatting corrected
- ✅ Import sorting fixed
- ✅ Unused imports removed
- ✅ Whitespace normalized
- ✅ Line length violations resolved

When fixes are available:
- Create branch: `chore/auto-health-check-YYYY-MM-DD`
- Create PR with all fixes
- Label: `automated`, `health-check`
- Ready for your review and merge

---

## Repository Auto-Discovery

**The monitor automatically discovers and monitors NEW repositories!**

How it works:
1. Monitor scans `/mnt/c/Users/be10cs1/github/*/*/` for git repositories
2. Any directory with a `.git` folder is automatically detected
3. Python projects (with `requirements.txt`) are actively monitored
4. First run includes the new repo on next scheduled execution

**New repos are automatically added** - no manual configuration needed.

---

## Repositories Being Monitored

**Currently monitoring 28 repositories:**

<details>
<summary>CAIN Projects (3)</summary>

- ai-agent-architecture
- cain-template
- openmetal-os-cloud
</details>

<details>
<summary>CTS Projects (4)</summary>

- afghan-konar-valley-visualization
- cts-code-metrics
- cts-gis-portfolio
- colin-tda
</details>

<details>
<summary>TDA Projects (16)</summary>

- tda-admin-management
- tda-agol-content-management
- tda-agol-metadata-tracking
- tda-agol-monitor-dependencies
- tda-code-metrics
- tda-ipp-reporting-tool
- tda-markitdown-helper
- tda-plan-verifications
- tda-supervisor-management
- tda-template
- tda-wsl-codex-setup
- tdf-agol-admin-insights
- tdf-agol-data-backups
- tdf-agol-vendor-services-cleanup
- tdf-burn-manager
- tdf-economic-report
- tdf-facilities
- tdf-gis-expressions
</details>

<details>
<summary>TT Projects (4)</summary>

- tt-chattanooga-crime
- tt-template
- tt-tennessee-public-areas
</details>

---

## Configuration

Edit `~/.claude/health-monitor/config.conf`:

```bash
# Monitoring schedule (cron format)
SCHEDULE="0 2 * * *"

# Repository discovery root
GITHUB_ROOT="/mnt/c/Users/be10cs1/github"

# Auto-fix options
AUTO_FIX_ENABLED="true"
AUTO_CREATE_PR="true"

# Monitoring tools to enable
ENABLE_RUFF="true"
ENABLE_BANDIT="true"
ENABLE_SAFETY="true"

# Report retention
KEEP_REPORTS_DAYS="30"
```

---

## Reports & Logs

### Health Reports

Generated daily for each repository:

**Location:** `~/.claude/health-monitor/reports/`

**Format:**
```markdown
# Health Check Report: repository-name

Generated: 2026-09-16 02:15:30
Repository: /path/to/repo
Branch: main

## Summary
- Critical Issues: 0
- Total Issues: 3
- Auto-fixes Applied: 2
- Status: ✓ Healthy

## Detailed Analysis
...

## Actions Taken
- Created PR: chore/auto-health-check-2026-09-16
```

### Logs

All activity is logged:

**Main Log:** `~/.claude/health-monitor/logs/cron.log`  
**Per-Run:** `~/.claude/health-monitor/logs/monitor_TIMESTAMP.log`  
**Per-Repo:** `~/.claude/health-monitor/logs/repo-name_DATE.log`

View logs:
```bash
# See recent activity
tail -50 ~/.claude/health-monitor/logs/cron.log

# Search for specific repo
grep "repository-name" ~/.claude/health-monitor/logs/*.log

# Watch in real-time
tail -f ~/.claude/health-monitor/logs/cron.log
```

---

## Manual Control

### Run Now
```bash
bash ~/.claude/health-monitor/run-monitor.sh
```

### Reset State
```bash
# Clear last check times (re-monitor all repos)
bash ~/.claude/health-monitor/reset-state.sh
```

### View Cron Log
```bash
bash ~/.claude/health-monitor/view-logs.sh
```

### List All Reports
```bash
bash ~/.claude/health-monitor/view-reports.sh
```

---

## Troubleshooting

### Monitor Not Running

Check if scheduled:
```bash
crontab -l | grep health-monitor
```

Verify cron daemon is running:
```bash
# Linux
sudo systemctl status cron

# macOS
brew services list | grep cron
```

### No Reports Generated

Check for errors:
```bash
bash ~/.claude/health-monitor/run-monitor.sh 2>&1 | head -50
```

View recent logs:
```bash
tail ~/.claude/health-monitor/logs/cron.log
```

### Missing Python Tools

Install required tools:
```bash
pip install ruff bandit safety
```

---

## System Requirements

- Python 3.11+
- git
- cron (for automatic scheduling)
- pip (Python package manager)

Optional but recommended:
- `gh` CLI for GitHub integration
- `ruff`, `bandit`, `safety` (auto-installed)

---

## Structure

```
cts-agent-monitoring/
├── bin/                        # Executable scripts
│   ├── health-monitor-controller.sh
│   ├── install.sh
│   └── ...
├── config/                     # Configuration templates
│   └── config.conf
├── docs/                       # Documentation
│   ├── SETUP.md
│   ├── USAGE.md
│   ├── AUTO-DISCOVERY.md
│   └── TROUBLESHOOTING.md
├── templates/                  # Report templates
│   └── health-report.md
├── examples/                   # Example reports
│   ├── report-example-healthy.md
│   ├── report-example-issues.md
│   └── ...
├── README.md                   # This file
├── LICENSE.md
└── CONTRIBUTING.md
```

---

## Features

### ✅ Automated Monitoring
- Runs daily on schedule
- Discovers new repos automatically
- Checks all Python projects
- No manual intervention needed

### ✅ Code Quality
- PEP 8 compliance (ruff)
- Complexity detection
- Import organization
- Unused code cleanup

### ✅ Security Scanning
- Hardcoded secrets detection
- SQL injection vulnerability scanning
- Insecure code patterns
- Cryptographic weakness detection

### ✅ Dependency Management
- Outdated package detection
- CVE scanning
- Version conflict detection
- Compatibility verification

### ✅ Auto-Fixes & PRs
- Automatic style corrections
- Import sorting
- PR creation for improvements
- Ready for review and merge

### ✅ Reporting
- Detailed health metrics
- Severity categorization
- Actionable recommendations
- Historical tracking

---

## License

Apache 2.0

---

## Author

Colin T. Stiles (colinstiles)

Tennessee Department of Agriculture

---

## Support

For issues or questions:
1. Check [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
2. Review logs: `~/.claude/health-monitor/logs/`
3. Open an issue on GitHub

---

**Status:** ✅ Active & Deployed

All 28 repositories are under continuous health monitoring.
