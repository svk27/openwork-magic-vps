#!/bin/bash

# Global Configuration
WORKSPACE_DIR="${HOME}/openwork_projects"

# Colors for UI
C_GREEN='\033[0;32m'
C_BLUE='\033[0;34m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_NC='\033[0m'

# 1) Set up dedicated workspace
setup_workspace() {
    if [ ! -d "$WORKSPACE_DIR" ]; then
        echo -e "${C_YELLOW}Initializing dedicated workspace at $WORKSPACE_DIR...${C_NC}"
        mkdir -p "$WORKSPACE_DIR"
        echo -e "${C_GREEN}✔ Workspace created successfully!${C_NC}"
    fi
}

# 2) Create Project with Git Support
create_project() {
    echo -e "\n${C_BLUE}--- Create New Project ---${C_NC}"
    read -p "Enter the new project name: " proj_name
    
    if [ -z "$proj_name" ]; then 
        echo -e "${C_RED}Project name cannot be empty. Aborting.${C_NC}"
        return
    fi
    
    target_dir="$WORKSPACE_DIR/$proj_name"
    if [ -d "$target_dir" ]; then
        echo -e "${C_RED}A project named '$proj_name' already exists!${C_NC}"
        return
    fi

    read -p "Enter Git repository URL (leave blank for local-only project): " git_url
    
    if [ -n "$git_url" ]; then
        echo -e "${C_YELLOW}Cloning repository... (Git will automatically prompt for credentials if private)${C_NC}"
        if git clone "$git_url" "$target_dir"; then
            echo -e "${C_GREEN}✔ Project '$proj_name' successfully cloned!${C_NC}"
        else
            echo -e "${C_RED}✘ Git clone failed. Check your URL or credentials.${C_NC}"
            echo -e "${C_YELLOW}Falling back to creating an empty directory instead...${C_NC}"
            mkdir -p "$target_dir"
            echo -e "${C_GREEN}✔ Empty project directory created at $target_dir${C_NC}"
        fi
    else
        mkdir -p "$target_dir"
        echo -e "${C_GREEN}✔ Local project '$proj_name' created at $target_dir${C_NC}"
    fi
}

# 3) View Projects
view_projects() {
    echo -e "\n${C_BLUE}--- Your Projects (${WORKSPACE_DIR}) ---${C_NC}"
    if [ -z "$(ls -A "$WORKSPACE_DIR")" ]; then
        echo -e "${C_YELLOW}No projects found. Use 'create' to add one.${C_NC}"
    else
        ls -1d "$WORKSPACE_DIR"/*/ 2>/dev/null | awk -F/ '{print "📂 " $(NF-1)}' || ls -1 "$WORKSPACE_DIR"
    fi
    echo "-----------------------------------------"
}

# 4) Start OpenWork
start_project() {
    echo -e "\n${C_BLUE}--- Start OpenWork ---${C_NC}"
    
    projects=()
    for d in "$WORKSPACE_DIR"/*/; do
        [ -d "$d" ] && projects+=("$(basename "$d")")
    done
    
    if [ ${#projects[@]} -eq 0 ]; then
        echo -e "${C_RED}No projects available. Create one first.${C_NC}"
        return
    fi

    echo "Available projects:"
    for i in "${!projects[@]}"; do
        echo " $((i+1))) ${projects[$i]}"
    done

    echo ""
    read -p "Select a project number to start (or 'q' to quit): " choice
    if [[ "$choice" == "q" ]]; then return; fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#projects[@]} ]; then
        echo -e "${C_RED}Invalid selection.${C_NC}"
        return
    fi

    selected_proj="${projects[$((choice-1))]}"
    target_path="$WORKSPACE_DIR/$selected_proj"
    
    echo -e "\n${C_BLUE}How would you like to start this project?${C_NC}"
    echo "1) Start with Default Flags (Recommended)"
    echo "2) Select Custom Flags"
    read -p "Choose an option [1-2]: " flag_choice

    # Default command parameters
    opt_remote=1
    opt_detach=0
    opt_approval=1
    opt_tui=0
    opt_docker=0

    if [ "$flag_choice" == "2" ]; then
        while true; do
            echo -e "\n${C_YELLOW}--- Toggle Flags ---${C_NC}"
            echo "1) [$( [ $opt_remote -eq 1 ] && echo -e "${C_GREEN}ON ${C_NC}" || echo -e "${C_RED}OFF${C_NC}" )] --remote-access (Binds to 0.0.0.0)"
            echo "2) [$( [ $opt_detach -eq 1 ] && echo -e "${C_GREEN}ON ${C_NC}" || echo -e "${C_RED}OFF${C_NC}" )] --detach        (Run in background)"
            echo "3) [$( [ $opt_approval -eq 1 ] && echo -e "${C_GREEN}ON ${C_NC}" || echo -e "${C_RED}OFF${C_NC}" )] --approval auto (Auto-approve AI execution)"
            echo "4) [$( [ $opt_tui -eq 1 ] && echo -e "${C_GREEN}ON ${C_NC}" || echo -e "${C_RED}OFF${C_NC}" )] --no-tui        (Disable interactive dashboard)"
            echo "5) [$( [ $opt_docker -eq 1 ] && echo -e "${C_GREEN}ON ${C_NC}" || echo -e "${C_RED}OFF${C_NC}" )] --sandbox docker(Run agent inside Docker)"
            echo "------------------------"
            echo -e "${C_BLUE}6) 🚀 RUN COMMAND NOW${C_NC}"
            
            read -p "Select a flag to toggle (1-5) or 6 to Run: " toggle
            case $toggle in
                1) opt_remote=$((1-opt_remote)) ;;
                2) opt_detach=$((1-opt_detach)) ;;
                3) opt_approval=$((1-opt_approval)) ;;
                4) opt_tui=$((1-opt_tui)) ;;
                5) opt_docker=$((1-opt_docker)) ;;
                6) break ;;
                *) echo -e "${C_RED}Invalid option.${C_NC}" ;;
            esac
        done
    fi

    # Build the command string
    cmd="openwork start --workspace \"$target_path\""
    if [ $opt_approval -eq 1 ]; then cmd+=" --approval auto"; fi
    if [ $opt_remote -eq 1 ]; then cmd+=" --remote-access"; fi
    if [ $opt_detach -eq 1 ]; then cmd+=" --detach"; fi
    if [ $opt_tui -eq 1 ]; then cmd+=" --no-tui"; fi
    if [ $opt_docker -eq 1 ]; then cmd+=" --sandbox docker"; fi
    
    echo -e "\n${C_GREEN}🚀 Starting OpenWork for '$selected_proj'...${C_NC}"
    echo -e "${C_YELLOW}Executing: $cmd${C_NC}\n"
    
    # Execute the generated command securely
    eval $cmd
}

# 5) Status / Stop Manager
check_status() {
    echo -e "\n${C_BLUE}--- OpenWork Connections Status ---${C_NC}"
    
    # Search for running openwork processes (excluding the grep search itself)
    IFS=$'\n' read -r -d '' -a processes < <(ps -eo pid,cmd | grep "[o]penwork start" && printf '\0')
    
    if [ ${#processes[@]} -eq 0 ] || [ -z "${processes[0]}" ]; then
        echo -e "${C_YELLOW}No running OpenWork connections found.${C_NC}"
        return
    fi

    echo "Running instances:"
    for i in "${!processes[@]}"; do
        pid=$(echo "${processes[$i]}" | awk '{print $1}')
        # Extract the workspace path from the command if possible for readability
        cmd_path=$(echo "${processes[$i]}" | grep -oP '(?<=--workspace )[^ ]+' || echo "Unknown Workspace")
        echo " $((i+1))) PID: $pid | Workspace: $cmd_path"
    done

    echo ""
    read -p "Enter the number to STOP an instance (or 'q' to go back): " choice
    if [[ "$choice" == "q" ]]; then return; fi

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#processes[@]} ]; then
        idx=$((choice-1))
        pid_to_kill=$(echo "${processes[$idx]}" | awk '{print $1}')
        echo -e "${C_YELLOW}Stopping OpenWork (PID: $pid_to_kill)...${C_NC}"
        kill "$pid_to_kill"
        echo -e "${C_GREEN}✔ Process terminated successfully.${C_NC}"
    else
        echo -e "${C_RED}Invalid selection.${C_NC}"
    fi
}

# Interactive Menu
interactive_menu() {
    while true; do
        echo -e "\n${C_BLUE}=== 🛠️ EasyWorkspace Manager ===${C_NC}"
        echo "1) ➕ Create a new project"
        echo "2) 📁 View existing projects"
        echo "3) 🚀 Start OpenWork for a project"
        echo "4) 📊 Status / Stop running connections"
        echo "5) ❌ Exit"
        read -p "Select an option [1-5]: " option
        
        case $option in
            1) create_project ;;
            2) view_projects ;;
            3) start_project ;;
            4) check_status ;;
            5) echo -e "${C_GREEN}Goodbye!${C_NC}"; exit 0 ;;
            *) echo -e "${C_RED}Invalid option. Please enter 1-5.${C_NC}" ;;
        esac
    done
}

# Main Execution Flow
setup_workspace

# Route commands
case "$1" in
    create) create_project ;;
    view) view_projects ;;
    start) start_project ;;
    status) check_status ;;
    "") interactive_menu ;;
    *) 
        echo -e "${C_RED}Unknown command: $1${C_NC}"
        echo "Usage: easyworkspace [create | view | start | status]"
        exit 1 
        ;;
esac
