#!/bin/bash

print_menu() {
    echo "choose an option 1-9:"
    echo "1) Create a CSV file and set it as the current file"
    echo "2) Select a file as current"
    echo "3) Display the current file"
    echo "4) Add a new row for a specific plant"
    echo "5) Run the improved Python code with parameters for a specific plant to create diagrams"
    echo "6) Update values in a specific row in the file by plant name"
    echo "7) Delete a row by row index or by plant"
    echo "8) Print the plant with the highest average number of leaves"
    echo "9) Exit"
}

current_file=""
while true; do
    print_menu
    read -p "Enter your choice: " choice
    
    case $choice in
        1)
            echo "Enter the csv file name:"
            read file_name
            touch "$file_name.csv"
            current_file=$file_name
            echo "Created CSV and set it as the current file"
            ;;
        2)
            echo "Enter the exist file name:"
            read file_name
            if [[ -f $file_name ]]; then
                current_file=$file_name
                echo "Selected file as current"
            else
                echo "File does not exist"
            fi
            ;;
        3)
            if [[ -f $current_file ]]; then
                cat $current_file
            else
                echo "No current file selected"
            fi
            ;;
        4)
            echo "You chose to add a new row for a specific plant"   
            echo "Enter the line to add current file:"
            read line
            if [[ -f $current_file ]]; then
               echo $line >> $current_file
            else
                echo "No current file selected"
            fi
            ;;
        5)
            echo "You chose to run the improved Python code with parameters for a specific plant to create diagrams"
            echo "Enter the plant name:"
            read plant_name 
            line=$(grep "$plant_name" "$current_file")
            if [[ -z $line ]]; then
                echo "Plant not found"
                continue
            fi
            IFS=',' read -ra split_line <<< "$line"
            if [[ ${#split_line[@]} != 4 ]]; then
                echo "Invalid line"
                continue
            fi

            # הסרת המרכאות הכפולות מהנתונים
            heighttt=$(echo  ${split_line[1]} | tr -d '"')
            leaf_counttt=$(echo  ${split_line[2]} | tr -d '"')
            dry_weighttt=$(echo  ${split_line[3]} | tr -d '"')

            python3 /home/saar/LINUX_Course_Project/Work/Q2/plant_plots.py \
              --plant ${split_line[0]} \
              --height ${heighttt} \
              --leaf_count ${leaf_counttt} \
              --dry_weight ${dry_weighttt}

            ;;
        6)
            echo "You chose to update values in a specific row in the file by plant name"
            echo "Enter the plant name:"
            read plant_name
            line2=$(grep "$plant_name" "$current_file")

 
            if [[ -z $line2 ]]; then
                echo "Plant not found"
                echo $line2
                continue
            fi
            IFS=',' read -ra split_line2 <<< "$line2"
            if [[ ${#split_line2[@]} != 4 ]]; then
                echo "Invalid line"
                continue
            fi
            echo "choose value to update in line (0,1,2,3) 0-3:   0 for name  1,2,3 arrays:"
            read val
            case $val in
                0)
                    echo "Enter the new plant name:"
                    read new_plant_name
                    split_line2[0]=$new_plant_name
                    sed -i "s#${plant_name}#${new_plant_name}#g" "$current_file"
                    ;;
                1)
                    echo "Enter the new height: start and end with quotation marks  " 
                    read new_height
                    split_line2[1]="\"$new_height\""
                    new_line=$(IFS=,; echo "${split_line2[*]}")  
                    sed -i "s#${line2}#${new_line}#" "$current_file"
                    ;;
                2)
                    echo "Enter the new leaf count:"
                    read new_leaf_count
                    split_line2[2]="\"$new_leaf_count\""
                    new_line=$(IFS=,; echo "${split_line2[*]}")  
                    sed -i "s#${line2}#${new_line}#" "$current_file"
                    ;;
                3)
                    echo "Enter the new dry weight:"
                    read new_dry_weight
                    split_line2[3]="\"$new_dry_weight\""
                    new_line=$(IFS=,; echo "${split_line2[*]}")  
                    sed -i "s#${line2}#${new_line}#" "$current_file"
                    ;;
                *)
                    echo "Invalid choice"
                    ;;
            esac
           
            
            ;;
        7)
            echo "You chose to delete a row by row index or by plant"
            echo "enter 1 for index or 2 for plant name"
            read choice3
            case $choice3 in
                1)
                    echo "Enter the row index to delete: start  from 1"
                    read row_index
                    sed -i "${row_index}d" "$current_file"
                    ;;
                2)
                    echo "Enter the plant name to delete:"
                    read plant_name
                    sed -i "/$plant_name/d" "$current_file"
                    ;;
                *)
                    echo "Invalid choice"
                    ;;
            esac

            ;;
        8)
            echo "You chose to print the plant with the highest average number of leaves"
            biggest_avg=0

            while IFS= read -r line4; do
                 IFS=',' read -ra split_line2 <<< "$line4"
                 if [[ ${#split_line2[@]} != 4 ]]; then
                    echo "Invalid line"
                 continue
                 fi

                 # Removing double quotes from the Leaf Count field
                 leaf_count_str=$(echo "${split_line2[2]}" | tr -d '"')

                 # Splitting the values within Leaf Count into numbers
                 IFS=' ' read -ra leaf_count_arr <<< "$leaf_count_str"

                 sum=0
                 for num in "${leaf_count_arr[@]}"; do
                  sum=$((sum + num))
                 done

                 avg=$((sum / ${#leaf_count_arr[@]}))
                 if [[ $avg -gt $biggest_avg ]]; then
                    biggest_avg=$avg
                    biggest_avg_plant="${split_line2[0]}"
                 fi

            done < "$current_file"

echo "The plant with the highest average number of leaves is: $biggest_avg_plant"

            ;;
        9)
            echo "You chose to exit"
            break
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
done