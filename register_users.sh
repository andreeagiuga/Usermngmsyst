#!/bin/bash

# Fișier CSV pentru utilizatori
USER_FILE="users.csv"

# Funcție pentru a verifica existența unui utilizator
user_exists() {
    local username="$1"
    grep -q "^${username}," "$USER_FILE"
}

# Funcție pentru a genera un ID unic
generate_id() {
    echo $(date +%s%N)
}

# Funcție pentru validarea emailului
validate_email() {
    local email="$1"
    [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]
}
# Funcție pentru înregistrarea unui utilizator nou
register_user() {
    local username="$1"
    local email="$2"
    local password="$3"

    if user_exists "$username"; then
        echo "Utilizatorul $username există deja."
        exit 1
    fi

    if ! validate_email "$email"; then
        echo "Adresa de email este invalidă."
        exit 1
    fi

    local id=$(generate_id)
    local home_dir="home/$username"

    # Adăugarea utilizatorului în fișierul CSV
    echo "$username,$email,$password,$id,$home_dir," >> "$USER_FILE"

    # Crearea directorului home
    mkdir -p "$home_dir"

    echo "Utilizatorul $username a fost înregistrat cu succes."
}

# Solicitarea detaliilor utilizatorului
echo "Introduceti numele de utilizator:"
read username
echo "Introduceti adresa de email:"
read email
echo "Introduceti parola:"
read -s password

# Apelarea funcției de înregistrare
register_user "$username" "$email" "$password"
