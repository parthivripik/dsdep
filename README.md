# dsdep - Data Science Deployment Tool

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Linux-blue.svg)](https://www.linux.org/)

**dsdep** is a command-line tool that automates the deployment of Python/Data Science projects on Linux servers with systemd service hardening, S3 model downloads, and environment configuration.

## Features

- 🚀 **One-command deployment** - Clone, setup, and run your project
- 🐍 **Environment management** - Works with conda or Python venv
- ☁️ **S3 Model Downloads** - Automatically download ML models from AWS S3
- 🔐 **Environment Setup** - Interactive or file-based `.env` configuration
- 🔄 **Auto-restart** - Monitors logs and restarts on hangs
- 🛡️ **Systemd hardening** - Creates proper service files with auto-recovery
- ✅ **Deployment verification** - Checks service status, logs, and files
- 📝 **Verbose output** - Clear progress and status information

## Installation

### Option 1: Quick Install (curl)

```bash
curl -sSL https://raw.githubusercontent.com/parthivripik/dsdep/main/install.sh | sudo bash
```

### Option 2: From Debian Package (.deb)

```bash
# Download the latest release
wget https://github.com/parthivripik/dsdep/releases/download/v1.1.0/dsdep_1.1.0-1_all.deb

# Install
sudo dpkg -i dsdep_1.1.0-1_all.deb
```

### Option 3: From Source

```bash
git clone https://github.com/parthivripik/dsdep.git
cd dsdep

# Install system-wide (requires sudo)
sudo make install

# Or install locally (no sudo)
make local-install
```

## Usage

### Basic Deployment

```bash
# Deploy with existing conda environment
sudo dsdep -r https://github.com/user/project -e /root/miniconda3/envs/myenv

# Deploy and create new conda environment
sudo dsdep -r https://github.com/user/project -c myproject-env

# Deploy using Python venv
sudo dsdep -r https://github.com/user/project --venv
```

### With S3 Model Downloads

```bash
# Interactive AWS credentials setup
sudo dsdep -r https://github.com/user/ml-project -c myenv \
    --s3-bucket my-models-bucket \
    --s3-prefix "production/models/" \
    --setup-env

# Using existing .env file
sudo dsdep -r https://github.com/user/ml-project -c myenv \
    --s3-bucket my-models-bucket \
    --s3-prefix "v2/weights/" \
    --env-file /path/to/.env

# Custom models directory
sudo dsdep -r https://github.com/user/ml-project -c myenv \
    --s3-bucket my-bucket \
    --s3-prefix "checkpoints/" \
    --models-dir "weights" \
    --setup-env
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
    --s3-bucket my-models-bucket \
    --s3-prefix "production/" \
    --env-file ~/.env.production \
    -t 300
```

## Options Reference

### Required Options

| Option | Description |
|--------|-------------|
| `-r, --repo <URL>` | Git repository URL (required) |

### Environment Options

| Option | Description | Default |
|--------|-------------|---------|
| `-e, --env <PATH>` | Conda environment path | - |
| `-c, --create-env <NAME>` | Create new conda env | - |
| `-v, --venv` | Use Python venv | false |
| `-p, --conda-profile <PATH>` | Conda profile script | Auto-detected |
| `-R, --requirements <PATH>` | Custom requirements.txt | Repo's or default |

### Service Options

| Option | Description | Default |
|--------|-------------|---------|
| `-n, --name <NAME>` | Service name | Repo name |
| `-m, --main <SCRIPT>` | Main Python script | main.py |
| `-a, --args <ARGS>` | Script arguments | - |
| `-l, --log-path <PATH>` | Log file path | ./logs/app.log |
| `-t, --timeout <SECONDS>` | Monitoring timeout | 600 |
| `-u, --user <USER>` | Run as user | root |
| `-d, --dest <PATH>` | Destination directory | /opt/dsdep-projects |

### AWS/S3 Model Download Options

| Option | Description | Default |
|--------|-------------|---------|
| `--s3-bucket <BUCKET>` | S3 bucket name | - |
| `--s3-prefix <PREFIX>` | S3 prefix/path | - |
| `--s3-region <REGION>` | AWS region | ap-south-1 |
| `--models-dir <DIR>` | Local models directory | models/ |
| `--model-ext <EXT>` | Model file extensions | .pt,.pth,.onnx,.weights,.h5,.pkl |

### Environment File Options

| Option | Description |
|--------|-------------|
| `--env-file <PATH>` | Copy existing .env file to project |
| `--setup-env` | Interactive mode to create .env |
| `--env-template <PATH>` | Use template and prompt for values |

### Other Options

| Option | Description |
|--------|-------------|
| `--skip-models` | Skip model download |
| `--skip-hardening` | Skip systemd setup (just env + models) |
| `--dry-run` | Preview without executing |
| `-h, --help` | Show help |
| `--version` | Show version |

## Environment File (.env)

The `.env` file is used to store AWS credentials and other configuration:

```bash
# AWS Credentials
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_REGION=ap-south-1

# S3 Configuration
S3_BUCKET=my-models-bucket
S3_MODEL_PREFIX=production/

# Custom Variables
DATABASE_URL=mongodb://localhost:27017
API_KEY=your-api-key
```

### Setup Methods

1. **Interactive** (`--setup-env`): Prompts for AWS credentials and custom variables
2. **Copy existing** (`--env-file <path>`): Copies an existing .env file
3. **Template** (`--env-template <path>`): Uses template and prompts for empty values

## Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                        dsdep v1.1.0                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Check Dependencies                                      │
│        │                                                    │
│        ▼                                                    │
│  2. Clone Repository ──────────────────────────────────────►│
│        │                                                    │
│        ▼                                                    │
│  3. Setup .env File ◄── Interactive / Copy / Template       │
│        │                                                    │
│        ▼                                                    │
│  4. Setup Python Environment (conda/venv)                   │
│        │                                                    │
│        ▼                                                    │
│  5. Install Dependencies (requirements.txt + boto3)         │
│        │                                                    │
│        ▼                                                    │
│  6. Download Models from S3 ◄── Uses .env credentials       │
│        │                      └─► models/*.pt               │
│        ▼                                                    │
│  7. Run Hardening Script                                    │
│        │  └─► runner.py                                     │
│        │  └─► service.sh                                    │
│        │  └─► systemd .service file                         │
│        ▼                                                    │
│  8. Verify Deployment                                       │
│        │  └─► Check files, service, logs                    │
│        ▼                                                    │
│  9. Print Summary & Exit                                    │
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
```

### Build Commands

```bash
# Build .deb package
make deb

# Run tests
make test

# Clean build artifacts
make clean
```

## Requirements

- **OS**: Linux with systemd (Ubuntu 18.04+, Debian 10+, CentOS 7+)
- **Shell**: Bash 4.0+
- **Python**: 3.8+
- **Tools**: git, curl
- **Optional**: conda/miniconda (for conda environments)
- **For S3**: boto3, python-dotenv (installed automatically)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/parthivripik/dsdep/issues)
- **Repository**: [https://github.com/parthivripik/dsdep](https://github.com/parthivripik/dsdep)
