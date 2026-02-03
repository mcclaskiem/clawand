# 🦞 OpenClaw on Apple Containers

Run [OpenClaw](https://github.com/openclaw/openclaw) — a personal AI assistant — inside a lightweight Linux container on your Mac using [Apple Containers](https://github.com/apple/container).

## Why Apple Containers?

Apple Containers offers a fundamentally different approach to running Linux containers on macOS compared to Docker:

| Feature | Docker for Mac | Apple Containers |
|---------|---------------|------------------|
| **Architecture** | Single shared Linux VM for all containers | One lightweight VM per container |
| **Isolation** | Containers share a kernel inside the VM | Each container gets its own isolated VM |
| **Resource Usage** | Constant footprint (VM always running) | Zero idle resources — VMs start on-demand |
| **Startup Time** | Fast after VM boot | Sub-second container startup |
| **Networking** | Port forwarding required | Dedicated IP per container — no port mapping needed |
| **File System** | `osxfs` with I/O latency issues | Native EXT4 block devices |

**Key benefits of Apple Containers:**
- **Better security** — each container is fully isolated in its own micro-VM
- **Lower overhead** — no background VM consuming resources when idle
- **Native macOS integration** — built with Swift, uses Virtualization.framework
- **Cleaner networking** — dedicated IPs eliminate port conflict headaches

> 📖 For a deeper comparison, see: [Apple Native Containers vs Docker: A Game-Changer or Just Hype?](https://medium.com/@dileepapraveen32/apple-native-containers-vs-docker-a-game-changer-or-just-hype-dbab18a675b3)

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
openclaw gateway --port 18789 --bind lan
```

> ⚠️ **Important:** You must use `--bind lan` (or set `gateway.bind: "lan"` in your `openclaw.json`) for the gateway to be accessible from the host machine. The default `loopback` binding only allows connections from inside the container. You can also change this setting interactively by running `openclaw config`.

### 5. Pair your host machine

When connecting to OpenClaw from your host machine (via WebChat, macOS app, or mobile nodes), you need to pair the device for security.

1. Open the WebChat UI at **http://localhost:18789**
2. You will most likely see an error due to a pairing issue between the container and host machine
3. Inside the container, list pending device pairing requests:

```bash
openclaw devices list
```

4. Approve the device:

```bash
openclaw devices pair <device-id>
```

Or approve all pending devices:

```bash
openclaw devices pair --all
```

To remove a paired device:

```bash
openclaw devices remove <device-id>
```

See the [OpenClaw Gateway Pairing Docs](https://docs.openclaw.ai/gateway/pairing) for more details.

Once running, access the OpenClaw web UI at: **http://localhost:18789** or **http://127.0.0.1:18789**

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
