# sshb - SSH Buddy

A Tamagotchi-style virtual pet that lives in your terminal. Take care of your
ASCII cat between terminal sessions - feed it, play with it, put it to sleep,
and keep it happy and healthy. Your buddy's stats decay over time via a
background service, so check in regularly or face the consequences.

```
    /\_/\
   ( ^.^ )
    > ~ <
   /|   |\
  (_|   |_)
```

## Features

- Persistent pet state that survives across terminal sessions
- ASCII art cat with animated expressions based on mood
- Four core stats: Hunger, Energy, Happiness, Health
- Background daemon decays stats every 5 minutes via systemd
- Bash prompt integration shows pet status next to your hostname
- Interactive mode for quick care sessions
- Pet aging, mood system, and lifetime stat tracking

## Requirements

- Ubuntu 18.04+ (or any systemd-based Linux distro)
- Bash 4.0+
- systemd (for background service - optional, can run daemon manually)

## Installation

```bash
git clone <repo-url> sshb
cd sshb
chmod +x install.sh
./install.sh
```

The installer will:
1. Copy `sshb` and `sshb-daemon` to `~/.local/bin/`
2. Install a systemd user service for background stat decay
3. Enable and start the daemon
4. Initialize your pet

After install, run:
```bash
source ~/.bashrc
```

## Quick Start

```bash
# See your buddy
sshb

# Enter interactive mode
sshb interactive

# Care for your buddy
sshb feed
sshb play
sshb sleep
sshb wake

# Add pet to your terminal prompt
sshb install-prompt
source ~/.bashrc
```

## Commands

### Care Commands
| Command | Description |
|---------|-------------|
| `sshb feed` | Feed your buddy (+20-35 hunger, +5 happiness) |
| `sshb play` | Play with your buddy (+20-35 happiness, -10 energy) |
| `sshb sleep` | Put your buddy to bed (energy restores over time) |
| `sshb wake` | Wake your buddy up early |

### Info Commands
| Command | Description |
|---------|-------------|
| `sshb` or `sshb status` | Full status panel with ASCII art and stat bars |
| `sshb mini` | Compact status display |
| `sshb prompt` | One-line status for bash prompt integration |
| `sshb interactive` | Interactive TUI with single-key commands |

### Management Commands
| Command | Description |
|---------|-------------|
| `sshb rename <name>` | Rename your buddy |
| `sshb revive` | Bring back a dead buddy (reset stats to 50%) |
| `sshb reset` | Start completely over with a new pet |
| `sshb install-prompt` | Add buddy status to your bash prompt |
| `sshb uninstall-prompt` | Remove buddy from your bash prompt |

## How Stats Work

Stats range from 0 to 100. The background daemon ticks every 5 minutes:

- **Hunger** decays by 3 per tick - feed regularly
- **Energy** decays by 2 per tick - let your pet sleep to restore
- **Happiness** decays by 1 per tick - play often
- **Health** is the average of the other three stats

While sleeping, energy restores by 5 per tick instead of decaying. Your pet
wakes up automatically when energy reaches 100.

If all three stats hit zero, your pet dies. Use `sshb revive` to bring it back.

## Moods

Your pet's mood (and ASCII expression) changes based on average stats:

| Average | Mood | Face |
|---------|------|------|
| 80-100 | Ecstatic | `( ^o^ )` |
| 60-79 | Happy | `( ^.^ )` |
| 40-59 | Okay | `( -.- )` |
| 20-39 | Sad | `( T.T )` |
| 0-19 | Miserable | `( ;_; )` |
| Sleeping | Sleeping | `( -.- ) z` |
| Dead | Dead | `( x.x )` |

## Prompt Integration

After running `sshb install-prompt`, your terminal prompt looks like:

```
[Pixel(^.^) H:80 E:65 J:90] user@hostname:~/projects$
```

The prompt color changes based on overall health:
- Green: average 70+
- Yellow: average 40-69
- Red: average below 40

## Systemd Service

The background daemon runs as a systemd user service:

```bash
# Check daemon status
systemctl --user status sshb

# Restart daemon
systemctl --user restart sshb

# View daemon logs
journalctl --user -u sshb -f

# Or check the log file directly
cat ~/.sshb/daemon.log
```

If systemd user services are not available, run the daemon manually:

```bash
nohup sshb-daemon &
```

## File Locations

| Path | Purpose |
|------|---------|
| `~/.local/bin/sshb` | Main CLI command |
| `~/.local/bin/sshb-daemon` | Background decay daemon |
| `~/.sshb/state` | Pet state file (plain text key=value) |
| `~/.sshb/daemon.log` | Daemon activity log |
| `~/.config/systemd/user/sshb.service` | Systemd service definition |

## Uninstall

```bash
cd sshb
chmod +x uninstall.sh
./uninstall.sh
source ~/.bashrc
```

## Tips

- Feed your buddy before long meetings
- Put your buddy to sleep before logging off for the night
- If you forget, your buddy's stats will decay while you are away
- The interactive mode (sshb i) is the fastest way to do multiple actions
- Name your buddy something fun with `sshb rename MrWhiskers`

## License

GNU General Public License
