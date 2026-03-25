# Git Cheat Sheet — Primo Designs

## The Daily Workflow

### Sitting down to work? Pull first.
```bash
cd ~/Projects/primo-os    # (or whichever project)
git pull
```
This grabs any changes you pushed from another computer.

### Done working? Push your changes.
```bash
git add .
git commit -m "describe what you changed"
git push
```
This sends your changes to GitHub so your other computers can get them.

### The golden rule
**Pull before you work. Push when you're done.**

---

## Common Commands

| What you want to do | Command |
|---|---|
| See what files changed | `git status` |
| See the actual changes | `git diff` |
| Pull latest from GitHub | `git pull` |
| Stage all changes | `git add .` |
| Stage one file | `git add filename.js` |
| Commit staged changes | `git commit -m "your message"` |
| Push to GitHub | `git push` |
| See recent history | `git log --oneline -10` |

---

## "Oh No" Scenarios

### I made changes but want to undo everything
```bash
git checkout .
```
Throws away all uncommitted changes. Be careful — this can't be undone.

### I committed but haven't pushed yet and want to undo
```bash
git reset --soft HEAD~1
```
Undoes the commit but keeps your changes.

### I'm getting merge conflicts
This happens when you changed the same file on two computers. Git will mark the conflicts in the file like this:
```
<<<<<<< HEAD
your version
=======
the other version
>>>>>>>
```
Edit the file to keep what you want, remove the markers, then:
```bash
git add .
git commit -m "resolved merge conflict"
git push
```

### I forgot to pull and now git push is rejected
```bash
git pull
```
If there are no conflicts, git will merge automatically and you can push. If there are conflicts, see above.

---

## Setting Up a New Computer

```bash
# 1. Install Git: https://git-scm.com
# 2. Install GitHub CLI: https://cli.github.com
# 3. Log in
gh auth login

# 4. Clone the setup repo and run it
git clone https://github.com/Primo217/primo-setup.git ~/Projects/primo-setup
bash ~/Projects/primo-setup/setup.sh
```

That's it. All your repos are cloned and ready to go.
