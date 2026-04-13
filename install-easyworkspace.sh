#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}      Installing EasyWorkspace Helper Tool...         ${NC}"
echo -e "${BLUE}======================================================${NC}"

# Define the target location for the executable
TARGET_BIN="/usr/local/bin/easyworkspace"

# We use cat to pipe the full EasyWorkspace tool into the global binary folder.
sudo bash -c "cat << 'EOF' > $TARGET_BIN
#!/bin/bash

WORKSPACE_DIR=\"\${HOME}/openwork_projects\"
C_GREEN='\033[0;32m'
C_BLUE='\033[0;34m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_NC='\033[0m'

setup_workspace() {
    if [ ! -d \"\$WORKSPACE_DIR\" ]; then
        echo -e \"\${C_YELLOW}Initializing workspace at \$WORKSPACE_DIR...\${C_NC}\"
        mkdir -p \"\$WORKSPACE_DIR\"
        echo -e \"\${C_GREEN}✔ Workspace created!\${C_NC}\"
    fi
}

create_project() {
    echo -e \"\n\${C_BLUE}--- Create New Project ---\${C_NC}\"
    read -p \"Enter the new project name: \" proj_name
    [ -z \"\$proj_name\" ] && return
    
    target_dir=\"\$WORKSPACE_DIR/\$proj_name\"
    if [ -d \"\$target_dir\" ]; then echo -e \"\${C_RED}Already exists!\${C_NC}\"; return; fi

    read -p \"Enter Git repository URL (leave blank for local): \" git_url
    if [ -n \"\$git_url\" ]; then
        git clone \"\$git_url\" \"\$target_dir\" || mkdir -p \"\$target_dir\"
    else
        mkdir -p \"\$target_dir\"
    fi
}

view_projects() {
    echo -e \"\n\${C_BLUE}--- Your Projects ---\${C_NC}\"
    ls -1d \"\$WORKSPACE_DIR\"/*/ 2>/dev/null | awk -F/ '{print \"📂 \" \$(NF-1)}' || ls -1 \"\$WORKSPACE_DIR\"
}

start_project() {
    echo -e \"\n\${C_BLUE}--- Start OpenWork ---\${C_NC}\"
    projects=()
    for d in \"\$WORKSPACE_DIR\"/*/; do [ -d \"\$d\" ] && projects+=(\"\$(basename \"\$d\")\"); done
    [ \${#projects[@]} -eq 0 ] && return

    for i in \"\${!projects[@]}\"; do echo \" \$((i+1))) \${projects[\$i]}\"; done
    read -p \"Select a project to start: \" choice
    if ! [[ \"\$choice\" =~ ^[0-9]+$ ]] || [ \"\$choice\" -lt 1 ] || [ \"\$choice\" -gt \${#projects[@]} ]; then return; fi
    target_path=\"\$WORKSPACE_DIR/\${projects[\$((choice-1))]}\"
    
    echo \"1) Default Flags  2) Custom Flags\"
    read -p \"Choice: \" flag_choice

    opt_remote=1; opt_detach=1; opt_approval=1; opt_tui=1; opt_docker=0

    if [ \"\$flag_choice\" == \"2\" ]; then
        while true; do
            echo -e \"\n1) [\$([ \$opt_remote -eq 1 ] && echo 'ON' || echo 'OFF')] --remote-access\"
            echo \"2) [\$([ \$opt_detach -eq 1 ] && echo 'ON' || echo 'OFF')] --detach\"
            echo \"3) [\$([ \$opt_approval -eq 1 ] && echo 'ON' || echo 'OFF')] --approval auto\"
            echo \"4) [\$([ \$opt_tui -eq 1 ] && echo 'ON' || echo 'OFF')] --no-tui\"
            echo \"5) [\$([ \$opt_docker -eq 1 ] && echo 'ON' || echo 'OFF')] --sandbox docker\"
            echo \"6) RUN\"
            read -p \"Toggle: \" toggle
            case \$toggle in
                1) opt_remote=\$((1-opt_remote)) ;; 2) opt_detach=\$((1-opt_detach)) ;;
                3) opt_approval=\$((1-opt_approval)) ;; 4) opt_tui=\$((1-opt_tui)) ;;
                5) opt_docker=\$((1-opt_docker)) ;; 6) break ;;
            esac
        done
    fi

    cmd=\"openwork start --workspace \\\"\$target_path\\\"\"
    [ \$opt_approval -eq 1 ] && cmd+=\" --approval auto\"
    [ \$opt_remote -eq 1 ] && cmd+=\" --remote-access\"
    [ \$opt_detach -eq 1 ] && cmd+=\" --detach\"
    [ \$opt_tui -eq 1 ] && cmd+=\" --no-tui\"
    [ \$opt_docker -eq 1 ] && cmd+=\" --sandbox docker\"
    
    echo -e \"\${C_YELLOW}Executing: \$cmd\${C_NC}\"
    eval \$cmd
}

check_status() {
    echo -e \"\n\${C_BLUE}--- Connections Status ---\${C_NC}\"
    IFS=$'\n' read -r -d '' -a processes < <(ps -eo pid,cmd | grep \"[o]penwork start\" && printf '\0')
    [ \${#processes[@]} -eq 0 ] && { echo -e \"\${C_YELLOW}No running connections.\${C_NC}\"; return; }

    for i in \"\${!processes[@]}\"; do
        pid=\$(echo \"\${processes[\$i]}\" | awk '{print \$1}')
        cmd_path=\$(echo \"\${processes[\$i]}\" | grep -oP '(?<=--workspace )[^ ]+' || echo \"Unknown Workspace\")
        echo \" \$((i+1))) PID: \$pid | Workspace: \$cmd_path\"
    done

    read -p \"Enter number to stop (or 'q' back): \" choice
    if [[ \"\$choice\" =~ ^[0-9]+$ ]] && [ \"\$choice\" -ge 1 ] && [ \"\$choice\" -le \${#processes[@]} ]; then
        pid_to_kill=\$(echo \"\${processes[\$((choice-1))]}\" | awk '{print \$1}')
        kill \"\$pid_to_kill\"
        echo -e \"\${C_GREEN}✔ Stopped PID \$pid_to_kill.\${C_NC}\"
    fi
}

interactive_menu() {
    while true; do
        echo -e \"\n\${C_BLUE}=== EasyWorkspace ===\${C_NC}\"
        echo \"1) Create project    2) View projects\"
        echo \"3) Start project     4) Status/Stop\"
        echo \"5) Exit\"
        read -p \"Option: \" option
        case \$option in 1) create_project ;; 2) view_projects ;; 3) start_project ;; 4) check_status ;; 5) exit 0 ;; esac
    done
}

setup_workspace
case \"\$1\" in create) create_project ;; view) view_projects ;; start) start_project ;; status) check_status ;; \"\") interactive_menu ;; esac
EOF"

sudo chmod +x $TARGET_BIN

echo -e "${GREEN}✔ EasyWorkspace successfully installed to ${TARGET_BIN}!${NC}\n"
echo -e "Use the ${YELLOW}easyworkspace status${NC} command anytime to check or kill background services."
