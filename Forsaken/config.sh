#!/usr/bin/bash

TEMP_FILE=$(mktemp)
CONFIG_REAL_PATH=$(dirname $0)
CONFIG_FILE="${CONFIG_REAL_PATH}/config_v2.json"

# Ensure config exists
if [ ! -f "$CONFIG_FILE" ]; then
    zenity --error --text="Config file not found: $CONFIG_FILE" --width=640 --height=480
    exit 1
fi

edit_globals() {
    current_roms=$(jq -r '.roms_path' "$CONFIG_FILE")
    current_lists=$(jq -r '.listas_path' "$CONFIG_FILE")
    current_ask=$(jq -r '.ask_to_save' "$CONFIG_FILE")
    
    # Convert bool to TRUE/FALSE for zenity
    if [ "$current_ask" == "true" ]; then ask_chk="TRUE"; else ask_chk="FALSE"; fi

    result=$(zenity --forms --title="Global Settings" \
        --text="Edit Global Configuration" \
        --icon="${CONFIG_REAL_PATH}/icon.png" \
        --add-entry="Roms Path" \
        --add-entry="Lists Path" \
        --add-combo="Ask to Save" --combo-values="true|false" \
        --width=640 --height=480 \
        --separator="|" \
        "${current_roms}" "${current_lists}" "${current_ask}")

    if [ $? -eq 0 ]; then
        new_roms=$(echo "$result" | awk -F'|' '{print $1}')
        new_lists=$(echo "$result" | awk -F'|' '{print $2}')
        new_ask=$(echo "$result" | awk -F'|' '{print $3}')

        jq --arg roms "$new_roms" \
           --arg lists "$new_lists" \
           --argjson ask "$new_ask" \
           '.roms_path = $roms | .listas_path = $lists | .ask_to_save = $ask' \
           "$CONFIG_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$CONFIG_FILE"
    fi
}

add_emulator() {
    result=$(zenity --forms --title="Add New Emulator" \
        --text="Enter details for new emulator" \
        --icon="${CONFIG_REAL_PATH}/icon.png" \
        --add-entry="System Name (e.g. snes)" \
        --add-entry="Command" \
        --add-combo="Use Forever Mode" --combo-values="true|false" \
        --add-combo="Accept Zip Files" --combo-values="true|false" \
        --width=640 --height=480 \
        --separator="|")

    if [ $? -eq 0 ]; then
        system=$(echo "$result" | awk -F'|' '{print $1}')
        cmd=$(echo "$result" | awk -F'|' '{print $2}')
        forever=$(echo "$result" | awk -F'|' '{print $3}')
        zip=$(echo "$result" | awk -F'|' '{print $4}')

        if [ -z "$system" ]; then
             zenity --error --text="System name cannot be empty."
             return
        fi
        
        # Determine if default bools are needed
        [ -z "$forever" ] && forever="false"
        [ -z "$zip" ] && zip="true"

        # Create new object and append
        jq --arg sys "$system" \
           --arg cmd "$cmd" \
           --argjson forever "$forever" \
           --argjson zip "$zip" \
           '.emulators += [{"system": $sys, "command": $cmd, "useForeverMode": $forever, "acceptZipFiles": $zip, "corePreferences": {}}]' \
           "$CONFIG_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$CONFIG_FILE"
           
        # Sort by system name after adding
        jq '.emulators |= sort_by(.system)' "$CONFIG_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$CONFIG_FILE"
    fi
}

edit_emulator() {
    system_name="$1"
    
    # Extract current values
    cmd=$(jq -r --arg sys "$system_name" '.emulators[] | select(.system == $sys) | .command | if type=="array" then join(" ; ") else . end' "$CONFIG_FILE")
    forever=$(jq -r --arg sys "$system_name" '.emulators[] | select(.system == $sys) | .useForeverMode // false' "$CONFIG_FILE")
    zip=$(jq -r --arg sys "$system_name" '.emulators[] | select(.system == $sys) | .acceptZipFiles // true' "$CONFIG_FILE")
    todo=$(jq -r --arg sys "$system_name" '.emulators[] | select(.system == $sys) | .todo // false' "$CONFIG_FILE")

    # Step 1: Edit Command (supports pre-fill via --entry-text)
    # We include the "Delete" option here to remove the intermediate screen
    new_cmd=$(zenity --entry \
        --title="Edit $system_name" \
        --text="Edit Command for $system_name:\n(Separate multiple commands with ' ; ')" \
        --icon="${CONFIG_REAL_PATH}/icon.png" \
        --entry-text="$cmd" \
        --extra-button="Delete Emulator" \
        --ok-label="Next" \
        --cancel-label="Cancel" \
        --width=640 --height=480)
    
    rc=$?
    
    # Check if "Delete Emulator" was clicked (it returns the label string)
    if [ "$new_cmd" == "Delete Emulator" ]; then
        delete_emulator "$system_name"
        return
    fi
    
    # If Cancel/Esc (non-zero exit)
    if [ $rc -ne 0 ]; then
        return
    fi
    
    # Step 2: Edit Flags using Checklist
    # Prepare default states
    if [ "$forever" == "true" ]; then s_forever="TRUE"; else s_forever="FALSE"; fi
    if [ "$zip" == "true" ]; then s_zip="TRUE"; else s_zip="FALSE"; fi
    if [ "$todo" == "true" ]; then s_todo="TRUE"; else s_todo="FALSE"; fi

    flags=$(zenity --list --checklist \
        --title="Edit $system_name Flags" \
        --icon="${CONFIG_REAL_PATH}/icon.png" \
        --text="Select enabled options:" \
        --column="Enabled" --column="Option" \
        "$s_forever" "Use Forever Mode" \
        "$s_zip" "Accept Zip Files" \
        "$s_todo" "Todo" \
        --separator="|" \
        --width=640 --height=480)
        
    if [ $? -eq 0 ]; then
        # Parse flags
        if [[ "$flags" == *"Use Forever Mode"* ]]; then new_forever="true"; else new_forever="false"; fi
        if [[ "$flags" == *"Accept Zip Files"* ]]; then new_zip="true"; else new_zip="false"; fi
        if [[ "$flags" == *"Todo"* ]]; then new_todo="true"; else new_todo="false"; fi

        # Update JSON
        jq --arg sys "$system_name" \
           --arg cmd "$new_cmd" \
           --argjson forever "$new_forever" \
           --argjson zip "$new_zip" \
           --argjson todo "$new_todo" \
           '(.emulators[] | select(.system == $sys)) |= (.command = (if ($cmd | contains(" ; ")) then ($cmd | split(" ; ")) else $cmd end) | .useForeverMode = $forever | .acceptZipFiles = $zip | .todo = $todo)' \
           "$CONFIG_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$CONFIG_FILE"
    fi
}

delete_emulator() {
    system_name="$1"
    zenity --question --text="Are you sure you want to PERMANENTLY delete '$system_name'?" --width=640 --height=480 --icon="${CONFIG_REAL_PATH}/icon.png"
    if [ $? -eq 0 ]; then
        jq --arg sys "$system_name" 'del(.emulators[] | select(.system == $sys))' "$CONFIG_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$CONFIG_FILE"
    fi
}

manage_emulators() {
    while true; do
        options=$(jq -r '.emulators[] | "\(.system)"' "$CONFIG_FILE" | sort)
        
        if [ -z "$options" ]; then
             zenity --info --text="No emulators found." --width=640 --height=480
             return
        fi

        # Just select the system
        selected=$(echo "$options" | zenity --list \
            --title="Select Emulator to Edit" \
            --icon="${CONFIG_REAL_PATH}/icon.png" \
            --column="System" \
            --height=480 --width=640 \
            --cancel-label="Back" \
            --ok-label="Edit" \
            --extra-button="Add New" \
            --hide-header)
        
        # If user clicked "Add New" button in the list view
        if [ "$selected" == "Add New" ]; then
            add_emulator
            continue
        fi

        # If a system was selected (Cancel returns non-zero, handled by loop break check below)
        if [ -n "$selected" ]; then
             edit_emulator "$selected"
        else
            # Empty selection or Cancel
            break
        fi
    done
}

# Main Loop
while true; do
    choice=$(zenity --info \
        --ok-label="Exit" \
        --icon="${CONFIG_REAL_PATH}/icon.png" \
        --title="Forsaken Config Manager" \
        --text="Welcome to Forsaken Config Manager.\nPlease select an option:" \
        --width=640 --height=480 \
        --extra-button="Manage Emulators" \
        --extra-button="Global Settings" \
        )

    case "$choice" in
        "Manage Emulators")
            manage_emulators
            ;;
        "Global Settings")
            edit_globals
            ;;
        *)
            break
            ;;
    esac
done

rm -f "$TEMP_FILE"
