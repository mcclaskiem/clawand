# 🦞 OpenClaw on Apple Containers

Run [OpenClaw](https://github.com/openclaw/openclaw) — a personal AI assistant — inside a lightweight Linux container on your Mac using [Apple Containers](https://github.com/apple/container).

## Requirements

- Mac with Apple Silicon
- macOS 26 or later
- [Apple Containers](https://github.com/apple/container) installed

## Quick Start

### 1. Build the image

```bash
container build --tag agent:latest .
```

### 2. Run the container

```bash
container run -t -i --memory 4g --cpus 8 \
  -p 127.0.0.1:18789:18789 \
  -v "$HOME/.openclaw:/home/agent/.openclaw" \
  --name agent agent:latest
```

**Flags explained:**
| Flag | Description |
|------|-------------|
| `-t -i` | Interactive terminal (TTY + stdin) |
| `--memory 4g` | Allocate 4GB RAM |
| `--cpus 8` | Allocate 8 CPU cores |
| `-p 127.0.0.1:18789:18789` | Map gateway port to localhost |
| `-v "$HOME/.openclaw:..."` | Persist OpenClaw config/data |
| `--name agent` | Name the container |

### 3. Inside the container

You'll be logged in as the `agent` user. Verify the installation:

```bash
node --version      # Should show v24.x.x
openclaw --version  # Should show OpenClaw version
```

### 4. Set up OpenClaw

Run the onboarding wizard:

```bash
openclaw onboard
```

Or start the gateway directly:

```bash
openclaw gateway --port 18789
```

Once running, access the OpenClaw web UI at: **http://localhost:18789**

## Container Management

| Action | Command |
|--------|---------|
| List running containers | `container ls` |
| List all containers | `container ls -a` |
| Stop container | `container stop agent` |
| Start stopped container | `container start agent` |
| Exec into running container | `container exec -it agent /bin/bash` |
| View logs | `container logs agent` |
| Delete container | `container rm agent` |
| Delete image | `container image rm agent:latest` |

## What's Included

The Dockerfile sets up:

- **Ubuntu Resolute** (20260106.1) base image
- **nvm** (Node Version Manager)
- **Node.js 24** via nvm
- **OpenClaw** via official installer
- Non-root `agent` user for security

## Persistent Data

The volume mount `-v "$HOME/.openclaw:/home/agent/.openclaw"` ensures your OpenClaw configuration, credentials, and workspace persist between container restarts.

Data stored includes:
- `openclaw.json` — configuration
- `credentials/` — channel auth tokens
- `workspace/` — agent workspace and skills
- `sessions/` — conversation history

## Customization

### Change resource allocation

Adjust memory and CPU in the run command:

```bash
container run -t -i --memory 8g --cpus 16 ...
```

### Use a different Node.js version

Edit the Dockerfile and change:

```dockerfile
RUN . "$NVM_DIR/nvm.sh" && nvm install 24 ...
```

to your desired version (e.g., `22`, `23`).

## Troubleshooting

### Node/npm not found

Make sure nvm is sourced. Run:

```bash
source ~/.bashrc
```

### Permission denied errors

Ensure the volume mount directory exists and is accessible:

```bash
mkdir -p ~/.openclaw
```

### Port already in use

Check if something else is using port 18789:

```bash
lsof -i :18789
```

## Links

- [OpenClaw Documentation](https://docs.openclaw.ai/)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Apple Containers](https://github.com/apple/container)
- [Apple Containerization (Swift package)](https://github.com/apple/containerization)

## License

MIT
