# dsdep - Data Science Deployment Tool

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Linux-blue.svg)](https://www.linux.org/)

**dsdep** is a command-line tool that automates the deployment of Python/Data Science projects on Linux servers with systemd service hardening.

## Features

- 🚀 **One-command deployment** - Clone, setup, and run your project
- 🐍 **Environment management** - Works with conda or Python venv
- 🔄 **Auto-restart** - Monitors logs and restarts on hangs
- 🛡️ **Systemd hardening** - Creates proper service files with auto-recovery
- ✅ **Deployment verification** - Checks service status, logs, and files
- 📝 **Verbose output** - Clear progress and status information

## Installation

### Option 1: Quick Install (curl)

```bash
curl -sSL https://raw.githubusercontent.com/ripiktech/dsdep/main/install.sh | sudo bash
```

### Option 2: From Debian Package (.deb)

```bash
# Download the latest release
wget https://github.com/ripiktech/dsdep/releases/download/v1.0.0/dsdep_1.0.0-1_all.deb

# Install
sudo dpkg -i dsdep_1.0.0-1_all.deb

# Fix any dependency issues
sudo apt-get install -f
```

### Option 3: From Source

```bash
git clone https://github.com/ripiktech/dsdep.git
cd dsdep

# Install system-wide (requires sudo)
sudo make install

# Or install locally (no sudo)
make local-install
```

### Option 4: Add PPA (Ubuntu/Debian)

```bash
# Add the repository
sudo add-apt-repository ppa:ripiktech/dsdep
sudo apt-get update

# Install
sudo apt-get install dsdep
```

## Usage

### Basic Usage

```bash
# Deploy a project with an existing conda environment
sudo dsdep -r https://github.com/user/project -e /root/miniconda3/envs/myenv

# Deploy and create a new conda environment
sudo dsdep -r https://github.com/user/project -c myproject-env

# Deploy using Python venv instead of conda
sudo dsdep -r https://github.com/user/project --venv
```

### Full Example

```bash
sudo dsdep \
    -r https://github.com/user/ml-project \
    -e /root/miniconda3/envs/production \
    -n ml-service \
    -m app.py \
    -a "--config prod --port 8080" \
    -l /var/log/ml-service/app.log \
    -t 300
```

### All Options

| Option | Description | Default |
|--------|-------------|---------|
| `-r, --repo <URL>` | Git repository URL (required) | - |
| `-e, --env <PATH>` | Conda environment path | - |
| `-R, --requirements <PATH>` | Custom requirements.txt | Repo's or default |
| `-n, --name <NAME>` | Service name | Repo name |
| `-m, --main <SCRIPT>` | Main Python script | main.py |
| `-a, --args <ARGS>` | Script arguments | - |
| `-l, --log-path <PATH>` | Log file path | ./logs/app.log |
| `-t, --timeout <SECONDS>` | Monitoring timeout | 600 |
| `-u, --user <USER>` | Run as user | root |
| `-d, --dest <PATH>` | Destination directory | /opt/dsdep-projects |
| `-p, --conda-profile <PATH>` | Conda profile script | Auto-detected |
| `-c, --create-env <NAME>` | Create new conda env | - |
| `-v, --venv` | Use Python venv | false |
| `--dry-run` | Preview without executing | false |

## What It Does

When you run `dsdep`, it performs these steps:

1. **Check Dependencies** - Verifies git, python3, conda/venv, systemctl
2. **Clone Repository** - Clones your project to the destination
3. **Setup Environment** - Creates or uses conda/venv environment
4. **Install Dependencies** - Installs from requirements.txt
5. **Run Hardening Script** - Creates:
   - `runner.py` - Monitors logs and restarts on hang
   - `<service>.sh` - Shell script to activate env and run
   - `/etc/systemd/system/<service>.service` - Systemd unit file
6. **Verify Deployment** - Checks service status, files, and logs
7. **Print Summary** - Shows useful commands for management

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        dsdep                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Clone Repo ──► 2. Setup Env ──► 3. Install Deps        │
│        │                │                   │               │
│        ▼                ▼                   ▼               │
│  /opt/project     conda/venv         requirements.txt      │
│                                                             │
│  4. Create Files ──► 5. Start Service ──► 6. Verify        │
│        │                    │                  │            │
│        ▼                    ▼                  ▼            │
│  runner.py            systemctl          Check status      │
│  service.sh           enable/start       Check logs        │
│  .service file                           Check files       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Service Management

After deployment, manage your service with:

```bash
# View status
sudo systemctl status <service-name>

# View real-time logs
sudo journalctl -u <service-name> -f

# Restart service
sudo systemctl restart <service-name>

# Stop service
sudo systemctl stop <service-name>

# Disable on boot
sudo systemctl disable <service-name>
```

## Building from Source

### Prerequisites

```bash
# For Debian/Ubuntu
sudo apt-get install dpkg-dev debhelper

# For RPM (optional)
sudo apt-get install alien rpm
```

### Build Commands

```bash
# Build .deb package
make deb

# Build .rpm package
make rpm

# Run tests
make test

# Clean build artifacts
make clean
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/awesome`)
3. Commit your changes (`git commit -m 'Add awesome feature'`)
4. Push to the branch (`git push origin feature/awesome`)
5. Open a Pull Request

## Requirements

- **OS**: Linux with systemd (Ubuntu 18.04+, Debian 10+, CentOS 7+)
- **Shell**: Bash 4.0+
- **Python**: 3.8+
- **Tools**: git, curl
- **Optional**: conda or miniconda (for conda environments)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/ripiktech/dsdep/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ripiktech/dsdep/discussions)
- **Email**: dev@ripiktech.com

## Acknowledgments

- Part of the [ripik_ds_helper](https://github.com/ripiktech/ripik_ds_helper) project
- Uses [ripikutils](https://github.com/ripiktech/ripikutils) for monitoring

---

Made with ❤️ by [Ripik Technologies](https://ripiktech.com)
