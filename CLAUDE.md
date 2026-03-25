# Primo Designs Workspace

## Identity
- User: TJ Turnbull (tj@primodesigns.net), Owner of Primo Designs
- HubSpot Owner ID: 161655613
- Firebase project: shopworks-421412
- Email domain: @primodesigns.net

## Workspace Projects
All projects live in `~/Projects/` and are cloned via `primo-setup/setup.sh`.

1. **primo-os/** — Order management MVP (Next.js 14, Firestore, SX ERP integration). Main branch.
2. **primo-lead-intelligence/** — Lead enrichment/scoring web app (Next.js 14, Firestore, Gmail API, OpenAI). Production.
3. **delivery-signature-app/** — PWA for delivery signatures (Firebase + BigQuery). Deployed.
4. **japan-trip-hub/** — Group trip planning app for Japan (vanilla HTML/CSS/JS, Firebase Firestore). Deployed on Vercel. GitHub: Primo217/japan-trip-hub.
5. **shopworks-cloud-functions/** — Firebase Cloud Functions for shopworks-421412.
6. **custom-catalog/** — Custom product catalog app.
7. **primo-intake-app/** — Client intake application.
8. **lead-reply-tracker/** — Tracks replies to lead outreach.
9. **email-intelligence/** — Email analysis tooling.
10. **email-monitor/** — Email monitoring service.
11. **ask-tj/** — AI assistant project.
12. **shower-thoughts/** — Side project.

## Daily Context
Read `DAILY_CONTEXT.md` in this directory for current CRM pipeline, calendar, and project status.

If DAILY_CONTEXT.md is more than 24 hours old, offer to refresh it by pulling fresh data from HubSpot, Google Calendar, and git repos. The refresh process:
1. Query HubSpot for open deals (owner 161655613), recent contacts, and open tasks
2. Query Google Calendar (primary, America/Chicago) for the next 7 days
3. Check git status of each project (branch, last commit, uncommitted changes)
4. Write updated DAILY_CONTEXT.md

To re-enable automatic twice-daily refreshes, create scheduled tasks:
- daily-context-morning: cron `57 6 * * 1-5`
- daily-context-evening: cron `53 16 * * 1-5`

## Key Technical Constraints
- All Firestore collections use `primo_` prefix (primo_leads, primo_users, primo_oauth_tokens, etc.)
- next-auth: use v4.24.13 (NOT v5)
- Tailwind: use v3 (^3.4.3), not v4
- cheerio 1.0+ has built-in types (no @types/cheerio)
- BigQuery project: shopworks-421412
- japan-trip-hub is vanilla HTML/CSS/JS (no framework) with Firebase Firestore for profile sync

## Setup
To set up this workspace on a new machine, see `primo-setup/setup.sh` or run:
```bash
gh auth login
git clone https://github.com/Primo217/primo-setup.git ~/Projects/primo-setup
bash ~/Projects/primo-setup/setup.sh
```
