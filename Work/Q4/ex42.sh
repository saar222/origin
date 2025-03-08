#!/bin/bash

# Default values
CSV_FILE=""
OUTPUT_DIR="Diagrams"
BACKUP_DIR="../../BACKUPS"
LOG_LEVEL="info"
VENV_DIR="../../myenv"
REQUIREMENTS_FILE="../../requirements.txt"

# Function to log messages
log_message() {
    if [[ "$LOG_LEVEL" == "info" || "$LOG_LEVEL" == "debug" ]]; then
        echo "$(date): $1" >> script_log.txt
    fi
}


# Function to log errors
log_error() {
    echo "$(date): ERROR - $1" >> error_log.txt
}

# Function to parse arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--path)
                CSV_FILE="$2"
                shift 2  #  shift 2 to get the next parameter
                ;;
            -o|--output-dir)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -b|--backup-dir)
                BACKUP_DIR="$2"
                shift 2
                ;;
            -l|--log-level)
                LOG_LEVEL="$2"
                shift 2
                ;;
            -v|--venv-name)
                VENV_DIR="$2"
                shift 2
                ;;
            -r|--requirements)
                REQUIREMENTS_FILE="$2"
                shift 2
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
}

# Parse arguments
parse_arguments "$@"

# Check if CSV file is provided
if [ -z "$CSV_FILE" ]; then
    log_error "CSV file path is required. Use -p or --path to specify."
    exit 1
fi

# Check if file is a CSV
if [[ ! "$CSV_FILE" =~ \.csv$ ]]; then
    log_error "File is not a CSV: $CSV_FILE"
    exit 1
fi

log_message "Using CSV file: $CSV_FILE"

# Create and activate VENV
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
    log_message "Created new virtual environment: $VENV_DIR"
else
    log_message "Virtual environment already exists: $VENV_DIR"
fi

source "$VENV_DIR/bin/activate"
if [ $? -ne 0 ]; then
    log_error "Failed to activate virtual environment"
    exit 1
fi

log_message "Activated virtual environment"

# Install required packages
if [ -f "$REQUIREMENTS_FILE" ]; then
    pip install -r "$REQUIREMENTS_FILE"
    if [ $? -eq 0 ]; then
        log_message "Installed required packages from $REQUIREMENTS_FILE"
    else
        log_error "Failed to install packages from $REQUIREMENTS_FILE"
        exit 1
    fi
else
    log_error "Requirements file not found: $REQUIREMENTS_FILE"
    exit 1
fi

# Process CSV file
mkdir -p "$OUTPUT_DIR"
while IFS=, read -r plant_name height leaf_count dry_weight; do
    plant_name=$(echo "$plant_name" | tr -d '"')
    height=$(echo "$height" | tr -d '"')
    leaf_count=$(echo "$leaf_count" | tr -d '"')
    dry_weight=$(echo "$dry_weight" | tr -d '"')
    
    log_message "Processing plant: $plant_name"
    
    plant_dir="$OUTPUT_DIR/$plant_name"
    mkdir -p "$plant_dir"
    
    (
        cd "$plant_dir" || exit
        python_output=$(python3 /home/saar/LINUX_Course_Project/Work/Q2/plant_plots.py \
            --plant "$plant_name" \
            --height "$height" \
            --leaf_count "$leaf_count" \
            --dry_weight "$dry_weight" 2>&1)

        if [ $? -eq 0 ]; then
            log_message "Successfully processed $plant_name. Output: $python_output"
        else
            log_error "Failed to process $plant_name. Output: $python_output"
        fi
    )
done < <(tail -n +2 "$CSV_FILE")

# Backup
mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/plants_backup_$(date +%Y%m%d_%H%M%S).tar.gz" "$OUTPUT_DIR"
log_message "Created backup in $BACKUP_DIR"

# Clean up
deactivate
log_message "Deactivated virtual environment"

log_message "Script completed successfully"
