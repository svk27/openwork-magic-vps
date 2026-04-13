# OpenWork Orchestrator & EasyWorkspace Setup

This repository contains tools to instantly set up and manage your OpenWork environment on a fresh **Ubuntu 24.04 LTS** system.

It includes two main tools:
1. **OpenWork Auto-Installer:** Installs dependencies and the core `openwork-orchestrator` package.
2. **EasyWorkspace Helper:** A custom CLI tool (`easyworkspace`) to easily create, view, and run your OpenWork projects.

## 🛠️ Tool 1: OpenWork Auto-Installer

This script takes care of the boring stuff so you can get straight to building. It automatically updates your system, installs `curl`, `nodejs`, and `npm`, and globally installs `openwork-orchestrator`.

### 🚀 Quick Install

Run this single command in your terminal:

```bash
curl -sSL https://raw.githubusercontent.com/svk27/openwork-magic-vps/refs/heads/main/install-openwork.sh | bash
```

### Manual Install

If you prefer to clone the repository:
```bash
git clone https://github.com/svk27/openwork-magic-vps.git
cd openwork-magic-vps
chmod +x install-openwork.sh
./install-openwork.sh
```

## 🚀 Tool 2: EasyWorkspace Helper

`easyworkspace` is a globally accessible command-line tool that manages your OpenWork folders, clones Git repositories natively, and provides a 1-click startup menu for your projects.

### 📥 1-Click Install

You can download and install the helper tool directly into your system's executable path `/usr/local/bin` using this one-liner:

```bash
sudo curl -sSL https://raw.githubusercontent.com/svk27/openwork-magic-vps/refs/heads/main/install-easyworkspace.sh -o /usr/local/bin/easyworkspace && sudo chmod +x /usr/local/bin/easyworkspace
```

### 💻 How to use EasyWorkspace

Once installed, you can call the tool from anywhere in your terminal. It will automatically create a dedicated `~/openwork_projects` folder for you.

* **Open the Interactive Menu:**
  ```bash
  easyworkspace
  ```

* **Jump straight to creating a project:** (Supports local folders or private/public Git URLs)
  ```bash
  easyworkspace create
  ```

* **Quickly list your projects:**
  ```bash
  easyworkspace view
  ```

* **Open the quick-start menu:** (Select a project number, and it automatically runs `openwork start` for you)
  ```bash
  easyworkspace start
  ```

## 🎯 What's Next?

Once you have installed both tools and created your first project using `easyworkspace create`, simply run `easyworkspace start`.

The terminal will output an **OpenWork URL** and an **OpenWork Owner Token**. Copy those details into your OpenWork Desktop App to securely connect to your remote workspace.

