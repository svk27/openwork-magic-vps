# OpenWork Orchestrator Auto-Installer

A simple, user-friendly bash script to automatically set up and install the [OpenWork Orchestrator](https://openworklabs.com/) on a fresh **Ubuntu 24.04 LTS** system. 

This script takes care of the boring stuff so you can get straight to building. It will automatically:
1. Update and upgrade your Ubuntu system.
2. Install necessary dependencies (`curl`, `nodejs`, `npm`).
3. Install the `openwork-orchestrator` package globally.

## 🚀 Quick Install (Recommended)

If you have the script hosted on GitHub (or a GitHub Gist), you can download and run it in a single command. 

Open your terminal and run:

```bash
curl -sSL https://raw.githubusercontent.com/svk27/openwork-magic-vps/refs/heads/main/install-openwork.sh | bash
