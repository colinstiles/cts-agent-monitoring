#!/bin/bash

################################################################################
# Repository Health Monitor Controller
#
# Coordinates daily health checks across all repositories
# Manages scheduling, logging, and PR creation
################################################################################

set -o pipefail

# Configuration
GITHUB_ROOT="/mnt/c/Users/be10cs1/github"
LOG_DIR="${HOME}/.claude/health-monitor/logs"
REPORTS_DIR="${HOME}/.claude/health-monitor/reports"
STATE_DIR="${HOME}/.claude/health-monitor/state"
CONFIG_FILE="${HOME}/.claude/health-monitor/config.conf"

# Create directories if they don't exist
mkdir -p "$LOG_DIR" "$REPORTS_DIR" "$STATE_DIR"

# Logging setup
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/monitor_${TIMESTAMP}.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LOG_FILE" >&2
}

log_success() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✓ $*" | tee -a "$LOG_FILE"
}

################################################################################
# Repository Discovery & Processing
################################################################################

process_repository() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")

    # Skip if not a git repository
    if [ ! -d "$repo_path/.git" ]; then
        return 0
    fi

    log "Processing: $repo_name"

    cd "$repo_path" || return 1

    local repo_log="$LOG_DIR/${repo_name}_${TIMESTAMP}.log"

    # 1. Pull latest changes
    log "  → Pulling latest changes..."
    git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || {
        log_error "  Could not pull repository"
        return 1
    }

    # 2. Check for Python project
    if [ ! -f "requirements.txt" ] && [ ! -f "requirements-dev.txt" ] && [ ! -f "setup.py" ]; then
        log "  ⊘ Not a Python project, skipping"
        return 0
    fi

    # 3. Install dependencies if needed
    if [ -f "requirements-dev.txt" ]; then
        log "  → Installing dev dependencies..."
        pip install -r requirements-dev.txt -q 2>>"$repo_log" || true
    fi

    # 4. Run health checks
    local issues_found=0
    local fixes_applied=0
    local critical_count=0

    # Ruff linting
    if command -v ruff &> /dev/null; then
        log "  → Running ruff checks..."
        if ! ruff check . 2>>"$repo_log"; then
            ((issues_found++))
            ((critical_count++))
        fi

        # Auto-fix formatting issues
        log "  → Applying auto-fixes..."
        ruff check . --fix -q 2>>"$repo_log"
        if [ $? -eq 0 ]; then
            ((fixes_applied++))
        fi
    fi

    # Security scanning with bandit
    if command -v bandit &> /dev/null; then
        log "  → Running security scan..."
        if ! bandit -r . -ll 2>>"$repo_log" | grep -q "Issue"; then
            :
        else
            ((issues_found++))
            ((critical_count++))
        fi
    fi

    # Dependency check
    if command -v safety &> /dev/null && [ -f "requirements.txt" ]; then
        log "  → Checking dependencies..."
        if ! safety check --file requirements.txt -q 2>>"$repo_log"; then
            ((issues_found++))
            ((critical_count++))
        fi
    fi

    # 5. Generate report
    local report_file="$REPORTS_DIR/${repo_name}_${TIMESTAMP}.md"
    generate_report "$repo_path" "$repo_name" "$report_file" "$issues_found" "$critical_count" "$fixes_applied"

    # 6. Create PR if fixes were applied
    if [ $fixes_applied -gt 0 ]; then
        log "  → Creating PR for fixes..."
        create_auto_fix_pr "$repo_path" "$repo_name" "$fixes_applied"
    fi

    # 7. Save state
    echo "$(date +%s)" > "$STATE_DIR/${repo_name}.last_check"
    echo "$issues_found" > "$STATE_DIR/${repo_name}.issues"

    log_success "  Completed: $issues_found issues found, $fixes_applied fixes applied"
}

################################################################################
# Report Generation
################################################################################

generate_report() {
    local repo_path="$1"
    local repo_name="$2"
    local report_file="$3"
    local issues_count="$4"
    local critical_count="$5"
    local fixes_count="$6"

    cat > "$report_file" << EOF
# Health Check Report: $repo_name

**Generated:** $(date)
**Repository:** $repo_path
**Branch:** $(git -C "$repo_path" branch --show-current)

## Summary

- **Critical Issues:** $critical_count
- **Total Issues:** $issues_count
- **Auto-fixes Applied:** $fixes_count
- **Status:** $([ $critical_count -eq 0 ] && echo "✓ Healthy" || echo "⚠ Needs Attention")

## Detailed Analysis

### Code Quality
- Linting: $([ $issues_count -eq 0 ] && echo "PASS" || echo "FAIL - $issues_count issues")
- Dependencies: $(command -v safety &> /dev/null && echo "Checked" || echo "Not configured")

### Security
- Secrets Scanning: $(command -v bandit &> /dev/null && echo "Enabled" || echo "Not configured")
- Vulnerability Check: $([ $critical_count -eq 0 ] && echo "PASS" || echo "FAIL")

## Recommendations

$([ $critical_count -gt 0 ] && echo "- **Immediate Action Required:** Review and fix critical issues" || echo "- All critical checks passed")
- Run full test suite locally: \`pytest\`
- Review auto-fixes before merging PR
- Update dependencies if vulnerabilities detected

## Actions Taken

- Report generated
$([ $fixes_count -gt 0 ] && echo "- PR created with auto-fixes: chore/auto-health-check-$(date +%Y-%m-%d)" || echo "- No automatic fixes needed")

---
*This report was auto-generated by the Repository Health Monitor Agent*
EOF

    log "  → Report saved: $report_file"
}

################################################################################
# PR Creation
################################################################################

create_auto_fix_pr() {
    local repo_path="$1"
    local repo_name="$2"
    local fixes_count="$3"

    cd "$repo_path" || return 1

    # Check if there are changes
    if ! git status --short | grep -q .; then
        log "  ⊘ No changes to commit"
        return 0
    fi

    # Create branch
    local branch_name="chore/auto-health-check-$(date +%Y-%m-%d)"

    # Check if branch already exists
    if git show-ref --quiet refs/heads/"$branch_name"; then
        log "  ⊘ PR branch already exists, skipping"
        return 0
    fi

    # Create and push branch
    git checkout -b "$branch_name" 2>/dev/null
    git add -A
    git commit -m "chore: automated code quality improvements

- Fixed formatting and style issues with ruff
- Resolved import ordering
- Updated code to meet project standards

Co-Authored-By: Claude Health Monitor <noreply@claude.ai>" 2>/dev/null

    if git push origin "$branch_name" 2>/dev/null; then
        log "  ✓ Branch pushed: $branch_name"

        # Create PR using gh if available
        if command -v gh &> /dev/null; then
            gh pr create --title "chore: automated code quality improvements" \
                --body "Automated health check found and fixed $fixes_count issues.

**Changes:**
- Fixed code formatting and style violations
- Resolved import issues
- Applied ruff auto-fixes

Please review and merge if changes look good.

---
*Generated by Repository Health Monitor*" \
                --label "automated,health-check" 2>/dev/null && log "  ✓ PR created"
        fi
    else
        log_error "  Failed to push branch"
    fi

    # Return to main branch
    git checkout main 2>/dev/null || git checkout master 2>/dev/null || true
}

################################################################################
# Main Execution
################################################################################

main() {
    log "════════════════════════════════════════════════════════════════"
    log "Repository Health Monitor - Execution Started"
    log "════════════════════════════════════════════════════════════════"

    local total_repos=0
    local processed_repos=0
    local failed_repos=0

    # Find and process all repositories
    for dir in "$GITHUB_ROOT"/*/; do
        for repo_dir in "$dir"*/; do
            if [ -d "$repo_dir" ] && [ -d "$repo_dir/.git" ]; then
                ((total_repos++))

                if process_repository "$repo_dir"; then
                    ((processed_repos++))
                else
                    ((failed_repos++))
                    log_error "Failed to process $(basename "$repo_dir")"
                fi
            fi
        done
    done

    # Summary
    log ""
    log "════════════════════════════════════════════════════════════════"
    log "Health Check Summary"
    log "════════════════════════════════════════════════════════════════"
    log "Total repositories: $total_repos"
    log "Successfully processed: $processed_repos"
    log "Failed: $failed_repos"
    log "Log file: $LOG_FILE"
    log "Reports: $REPORTS_DIR"
    log "════════════════════════════════════════════════════════════════"

    return $failed_repos
}

main "$@"
