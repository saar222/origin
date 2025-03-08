#!/bin/bash

# Function to log messages
log_message() {
    echo "$(date): $1" >> script_log.txt
}

# Function to log errors
log_error() {
    echo "$(date): ERROR - $1" >> error_log.txt
}


if [ -z "$1" ]; then # Check if CSV file was provided as argument
    log_error "Usage: $0 <csv_file>"
    exit 1
else
    CSV_FILE=$1
fi

if [[ ! "$CSV_FILE" =~ \.csv$ ]]; then # Check if file is a CSV with regex
    log_error "File is not a CSV: $CSV_FILE"
    exit 1
fi

log_message "Using CSV file: $CSV_FILE"

# Create and activate VENV
VENV_DIR="../../myenv"
if [ ! -d "$VENV_DIR" ]; then # Check if virtual environment exists
    python3 -m venv "$VENV_DIR"
    log_message "Created new virtual environment"
else
    log_message "Virtual environment already exists"
fi

source "$VENV_DIR/bin/activate"
if [ $? -ne 0 ]; then # Check if virtual environment was activated
    log_error "Failed to activate virtual environment"
    exit 1
fi

log_message "Activated virtual environment"

# This starts a loop that reads requirements file  line by line and installs each package
REQUIREMENTS_FILE="../../requirements.txt"
if [ -f "$REQUIREMENTS_FILE" ]; then # if file exist, Install required packages
    while IFS= read -r package || [[ -n "$package" ]]; do
        if [[ ! -z "$package" && ! "$package" =~ ^\s*# ]]; then
            pip install "$package" # Install package
            if [ $? -eq 0 ]; then   # Check if package was installed successfully
                log_message "Installed package: $package"
            else
                log_error "Failed to install package: $package"
            fi
        fi
    done < "$REQUIREMENTS_FILE"
    log_message "Finished installing required packages"
else
    log_error "requirements.txt not found"
    exit 1
fi


# Process CSV file
mkdir -p Diagrams
# Read CSV file line by line
while IFS=, read -r plant_name height leaf_count dry_weight; do
    # Remove quotes from CSV fields
    plant_name=$(echo "$plant_name" | tr -d '"') 
    height=$(echo "$height" | tr -d '"')   
    leaf_count=$(echo "$leaf_count" | tr -d '"')
    dry_weight=$(echo "$dry_weight" | tr -d '"')
    
    log_message "Processing plant: $plant_name"
    
    plant_dir="Diagrams/$plant_name"
    mkdir -p "$plant_dir"
    # Run Python script to create diagrams
    cd "$plant_dir"
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
    cd ../../
done < <(tail -n +2 "$CSV_FILE")  # Skip the header row



