#!/bin/bash

# Fișier CSV pentru utilizatori
USER_FILE="users.csv"

# Funcție pentru a verifica existența unui utilizator
user_exists() {
    local username="$1"
    grep -q "^${username}," "$USER_FILE"
}

# Funcție pentru generarea raportului
generate_report() {
    local username="$1"

    if ! user_exists "$username"; then
        echo "Utilizatorul $username nu există."
        exit 1
    fi

    local home_dir=$(grep "^${username}," "$USER_FILE" | cut -d',' -f5)

    local file_count=$(find "$home_dir" -type f | wc -l)
    local dir_count=$(find "$home_dir" -type d | wc -l)
    local total_size=$(du -sh "$home_dir" | cut -f1)

    local report_file="$home_dir/report.txt"

    echo "Raport pentru utilizatorul $username" > "$report_file"
    echo "Număr de fișiere: $file_count" >> "$report_file"
    echo "Număr de directoare: $dir_count" >> "$report_file"
    echo "Dimensiunea totală: $total_size" >> "$report_file"

    echo "Raportul a fost generat în $report_file"
}

# Solicitarea numelui de utilizator
echo "Introduceti numele de utilizator pentru care doriți să generați raportul:"
read username

# Apelarea funcției de generare a raportului
generate_report "$username"
