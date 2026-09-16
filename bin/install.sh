#!/bin/bash

################################################################################
# CTS Agent Monitoring - Installation Script
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MONITOR_HOME="${HOME}/.claude/health-monitor"

echo "🔧 Installing CTS Agent Monitoring"
echo ""

# Check prerequisites
echo "Checking prerequisites..."
if ! command -v git &> /dev/null; then
    echo "❌ git not found. Please install git."
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo "❌ python3 not found. Please install Python 3.11+"
    exit 1
fi

echo "✓ Prerequisites met"
echo ""

# Create monitor home
echo "Setting up monitoring directory..."
mkdir -p "$MONITOR_HOME"/{logs,reports,state}

# Copy scripts
echo "Installing scripts..."
cp "$SCRIPT_DIR"/health-monitor-controller.sh "$MONITOR_HOME/"
chmod +x "$MONITOR_HOME"/health-monitor-controller.sh

# Create wrapper script
cat > "$MONITOR_HOME/run-monitor.sh" << 'EOF'
#!/bin/bash
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
cd "$HOME" || exit 1
bash "$HOME/.claude/health-monitor/health-monitor-controller.sh" >> "$HOME/.claude/health-monitor/logs/cron.log" 2>&1
EOF
chmod +x "$MONITOR_HOME/run-monitor.sh"

# Create helper scripts
cat > "$MONITOR_HOME/view-logs.sh" << 'EOF'
#!/bin/bash
echo "Recent health check logs:"
echo ""
tail -50 ~/.claude/health-monitor/logs/cron.log
EOF
chmod +x "$MONITOR_HOME/view-logs.sh"

cat > "$MONITOR_HOME/view-reports.sh" << 'EOF'
#!/bin/bash
echo "Recent health check reports:"
echo ""
ls -lh ~/.claude/health-monitor/reports/ | tail -20
echo ""
echo "To view a specific report:"
echo "  cat ~/.claude/health-monitor/reports/REPO_NAME_*.md"
EOF
chmod +x "$MONITOR_HOME/view-reports.sh"

cat > "$MONITOR_HOME/reset-state.sh" << 'EOF'
#!/bin/bash
echo "Resetting monitor state..."
rm -f ~/.claude/health-monitor/state/*.last_check
rm -f ~/.claude/health-monitor/state/*.issues
echo "✓ State reset. Next run will treat all repos as new."
EOF
chmod +x "$MONITOR_HOME/reset-state.sh"

echo "✓ Scripts installed"
echo ""

# Copy configuration
echo "Setting up configuration..."
if [ ! -f "$MONITOR_HOME/config.conf" ]; then
    cp "$PROJECT_ROOT/config/config.conf" "$MONITOR_HOME/"
    echo "✓ Configuration file created"
    echo "  Edit: $MONITOR_HOME/config.conf"
else
    echo "⊘ Configuration already exists (skipping)"
fi

echo ""

# Install Python tools
echo "Installing Python monitoring tools..."
pip install -q ruff bandit safety 2>/dev/null || {
    echo "⚠ Some tools failed to install. Continuing anyway..."
}
echo "✓ Python tools installed"
echo ""

# Schedule cron job
echo "Setting up cron schedule..."
if command -v crontab &> /dev/null; then
    CURRENT_CRONTAB=$(crontab -l 2>/dev/null || echo "")

    if echo "$CURRENT_CRONTAB" | grep -q "health-monitor-controller"; then
        echo "⊘ Already scheduled in crontab"
    else
        CRON_ENTRY="0 2 * * * bash '$MONITOR_HOME/run-monitor.sh' 2>&1"
        (echo "$CURRENT_CRONTAB"; echo "$CRON_ENTRY") | crontab -
        echo "✓ Scheduled: Daily at 2:00 AM UTC"
    fi
else
    echo "⚠ crontab not found. Manual scheduling required."
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "✓ Installation Complete"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Monitor Home: $MONITOR_HOME"
echo ""
echo "Quick Commands:"
echo "  View logs:    bash $MONITOR_HOME/view-logs.sh"
echo "  View reports: bash $MONITOR_HOME/view-reports.sh"
echo "  Run now:      bash $MONITOR_HOME/run-monitor.sh"
echo "  Reset state:  bash $MONITOR_HOME/reset-state.sh"
echo ""
echo "Configuration:"
echo "  Edit: nano $MONITOR_HOME/config.conf"
echo "  Schedule: crontab -e"
echo ""
echo "════════════════════════════════════════════════════════════════"
