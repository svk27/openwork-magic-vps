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

# Create the bash script directly into the target bin directory
sudo bash -c "cat << 'EOF' > $TARGET_BIN
#!/bin/bash

# Global Configuration
WORKSPACE_DIR=\"\${HOME}/openwork_projects\"

# Colors for UI
C_GREEN='\033[0;32m'
C_BLUE='\033[0;34m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_NC='\033[0m'

# 1) Set up dedicated workspace
setup_workspace() {
    if [ ! -d \"\$WORKSPACE_DIR\" ]; then
        echo -e \"\${C_YELLOW}Initializing dedicated workspace at \$WORKSPACE_DIR...\${C_NC}\"
        mkdir -p \"\$WORKSPACE_DIR\"
        echo -e \"\${C_GREEN}✔ Workspace created successfully!\${C_NC}\"
    fi
}

# 2) Create Project with Git Support
create_project() {
    echo -e \"\n\${C_BLUE}--- Create New Project ---\${C_NC}\"
    read -p \"Enter the new project name: \" proj_name
    
    if [ -z \"\$proj_name\" ]; then 
        echo -e \"\${C_RED}Project name cannot be empty. Aborting.\${C_NC}\"
        return
    fi
    
    target_dir=\"\$WORKSPACE_DIR/\$proj_name\"
    if [ -d \"\$target_dir\" ]; then
        echo -e \"\${C_RED}A project named '\$proj_name' already exists!\${C_NC}\"
        return
    fi

    read -p \"Enter Git repository URL (leave blank for local-only project): \" git_url
    
    if [ -n \"\$git_url\" ]; then
        echo -e \"\${C_YELLOW}Cloning repository... (Git will automatically prompt for credentials if it is private)\${C_NC}\"
        if git clone \"\$git_url\" \"\$target_dir\"; then
            echo -e \"\${C_GREEN}✔ Project '\$proj_name' successfully cloned!\${C_NC}\"
        else
            echo -e \"\${C_RED}✘ Git clone failed. If using GitHub, ensure you are using a Personal Access Token (PAT) as your password.\${C_NC}\"
            echo -e \"\${C_YELLOW}Falling back to creating an empty directory instead...\${C_NC}\"
            mkdir -p \"\$target_dir\"
            echo -e \"\${C_GREEN}✔ Empty project directory created at \$target_dir\${C_NC}\"
        fi
    else
        mkdir -p \"\$target_dir\"
        echo -e \"\${C_GREEN}✔ Local project '\$proj_name' created at \$target_dir\${C_NC}\"
    fi
}

# 3) View Projects
view_projects() {
    echo -e \"\n\${C_BLUE}--- Your Projects (\${WORKSPACE_DIR}) ---\${C_NC}\"
    
    # Check if directory is empty
    if [ -z \"\$(ls -A \"\$WORKSPACE_DIR\")\" ]; then
        echo -e \"\${C_YELLOW}No projects found. Use 'create' to add one.\${C_NC}\"
    else
        # List directories only
        ls -1d \"\$WORKSPACE_DIR\"/*/ 2>/dev/null | awk -F/ '{print \"📂 \" \$(NF-1)}' || ls -1 \"\$WORKSPACE_DIR\"
    fi
    echo \"-----------------------------------------\"
}

# 4) Start OpenWork
start_project() {
    echo -e \"\n\${C_BLUE}--- Start OpenWork ---\${C_NC}\"
    
    # Store directories in an array
    projects=(\$(ls -1 \"\$WORKSPACE_DIR\"))
    
    if [ \${#projects[@]} -eq 0 ]; then
        echo -e \"\${C_RED}No projects available. Create one first.\${C_NC}\"
        return
    fi

    echo \"Available projects:\"
    for i in \"\${!projects[@]}\"; do
        echo \" \$((i+1))) \${projects[\$i]}\"
    done

    echo \"\"
    read -p \"Select a project number to start (or 'q' to quit): \" choice
    
    if [[ \"\$choice\" == \"q\" ]]; then return; fi

    if ! [[ \"\$choice\" =~ ^[0-9]+$ ]] || [ \"\$choice\" -lt 1 ] || [ \"\$choice\" -gt \${#projects[@]} ]; then
        echo -e \"\${C_RED}Invalid selection.\${C_NC}\"
        return
    fi

    selected_proj=\"\${projects[\$((choice-1))]}\"
    target_path=\"\$WORKSPACE_DIR/\$selected_proj\"
    
    echo -e \"\n\${C_GREEN}🚀 Starting OpenWork for '\$selected_proj'...\${C_NC}\"
    echo -e \"\${C_YELLOW}Executing: openwork start --workspace \$target_path --approval auto\${C_NC}\n\"
    
    # Execute the actual command
    openwork start --workspace \"\$target_path\" --approval auto
}

# Interactive Menu
interactive_menu() {
    while true; do
        echo -e \"\n\${C_BLUE}=== 🛠️ EasyWorkspace Manager ===\${C_NC}\"
        echo \"1) ➕ Create a new project\"
        echo \"2) 📁 View existing projects\"
        echo \"3) 🚀 Start OpenWork for a project\"
        echo \"4) ❌ Exit\"
        read -p \"Select an option [1-4]: \" option
        
        case \$option in
            1) create_project ;;
            2) view_projects ;;
            3) start_project ;;
            4) echo -e \"\${C_GREEN}Goodbye!\${C_NC}\"; exit 0 ;;
            *) echo -e \"\${C_RED}Invalid option. Please enter 1-4.\${C_NC}\" ;;
        esac
    done
}

# Main Execution Flow
setup_workspace

# Route commands
case \"\$1\" in
    create) create_project ;;
    view) view_projects ;;
    start) start_project ;;
    \"\") interactive_menu ;;
    *) 
        echo -e \"\${C_RED}Unknown command: \$1\${C_NC}\"
        echo \"Usage: easyworkspace [create | view | start]\"
        exit 1 
        ;;
esac
EOF"

# Make the newly created helper tool executable
sudo chmod +x $TARGET_BIN

echo -e "${GREEN}✔ EasyWorkspace successfully installed to ${TARGET_BIN}!${NC}\n"
echo -e "You can now run it from anywhere in your terminal:\n"
echo -e "  ${YELLOW}easyworkspace${NC}         (Opens the interactive UI)"
echo -e "  ${YELLOW}easyworkspace create${NC}  (Jump straight to project creation)"
echo -e "  ${YELLOW}easyworkspace view${NC}    (Quickly view your projects)"
echo -e "  ${YELLOW}easyworkspace start${NC}   (Jump straight to the OpenWork startup menu)"
echo -e "${BLUE}======================================================${NC}"
