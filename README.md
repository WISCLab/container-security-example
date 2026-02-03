# Container Security Example

This is an interactive example of best practices for securing Docker containers, demonstrated through a Django application. It uses a simple Django todo-list app as the workload, with security enhancements annotated directly in the source using searchable tags. While the example app is Django-specific, the container security principles apply broadly to any containerized application.

For more information on Docker security, see the [official security documentation](https://docs.docker.com/engine/security).

## Searchable Tags

Every security measure in the codebase is marked with a tag you can grep for:

```bash
grep -rn "<TAG-NAME>" .
```

| Tag | What it covers 
|---|---
| `<KERNEL-CAPABILITIES>` | Dropping Linux capabilities, running as a non-root user, preventing processes from gaining new privileges |
| `<CONTAINER-HARDENING>` | Read-only root filesystem, read-only volume mounts (preventing runtime tampering) |
| `<DAEMON-ATTACK-SURFACE>` | Keeping secrets out of source code and images; restricting debug mode and allowed hosts |
| `<BUILD-HYGIENE>` | Pinning dependency versions, excluding unnecessary files from the build context via `.dockerignore` |


## Quick Start & Rootless Mode

The containers in this project already run as a non-root user, but the Docker **daemon** itself also needs to be locked down. If an attacker escapes the container, a root-privileged daemon gives them full control of the host. Rootless mode eliminates that risk, but the setup differs across operating systems. A per-platform deploy script is included to handle daemon configuration and apply additional startup hardening. See the platform details below:

- **Linux** - The daemon runs natively with root privileges by default. To remove this attack surface, run the daemon in [rootless mode](https://docs.docker.com/engine/security/rootless/). This requires installing the `uidmap` package and configuring subordinate UID/GID ranges.
- **macOS** - Docker Desktop runs the daemon inside a lightweight Linux VM. The daemon runs as root *within* the VM, but the VM boundary isolates it from the host. Shared file mounts can still expose host directories to a container escape, so limit bind mounts to what is necessary. No rootless configuration is needed.
- **Windows** - Docker Desktop uses WSL 2 or Hyper-V to run a Linux VM, similar to macOS. The daemon is isolated inside the VM but still runs as root within it. The same file-sharing caveats apply. No rootless configuration is needed.

```bash
# Make migrations locally (using the pinned version)
pip install django==4.2.28 && python manage.py makemigrations todos

# If you're on linux
./deployment-scripts/deploy-linux.sh

# If you're on macos
./deployment-scripts/deploy-macos.sh

# If you're on windows
./deployment-scripts/deploy-windows.sh
```

> [!NOTE]
> The container is now running as non-root (appuser, uid 1000) with all
Linux capabilities dropped (cap_drop: ALL), no-new-privileges set, and
a read-only root filesystem (writable tmpfs at /tmp only).
Migrations run automatically at startup against ./db/db.sqlite3, which
is bind-mounted from the host so data persists across container restarts.
On Linux the deploy script also switches the Docker daemon to rootless
mode; on macOS/Windows the VM boundary already isolates the daemon.
