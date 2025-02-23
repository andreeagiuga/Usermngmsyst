#!/bin/bash

# Fișier CSV pentru utilizatori
USER_FILE="users.csv"
LOGGED_IN_USERS=()

# Funcție pentru a verifica existența unui utilizator
user_exists() {
    local username="$1"
    grep -q "^${username}," users.csv
}

is_user_logged_in() {
    local username="$1"
    for user in "${LOGGED_IN_USERS[@]}"; do
        if [ "$user" == "$username" ]; then
            return 0
        fi
    done
    return 1
}

# Funcție pentru autentificare
authenticate_user() {
    local username="$1"
    local password="$2"
# Verificarea dacă utilizatorul este deja logat
    if is_user_logged_in "$username"; then
        echo "Utilizatorul $username este deja logat."
        return 1
    fi

    if ! user_exists "$username"; then
        echo "Utilizatorul $username nu există."
        return 1
    fi

    local stored_password=$(grep "^${username}," "$USER_FILE" | cut -d',' -f3)
    if [ "$password" != "$stored_password" ]; then
        echo "Parola incorectă."
        return 1
    fi

    local home_dir=$(grep "^${username}," "$USER_FILE" | cut -d',' -f5)
    cd "$home_dir"

    # Actualizarea câmpului last_login
    local last_login=$(date)
    awk -F',' -v username="$username" -v last_login="$last_login" 'BEGIN { OFS = FS } { if ($1 == username) $6 = last_login }1' "../../$USER_FILE" > temp && mv temp "../../$USER_FILE"

    # Adăugarea utilizatorului în lista de utilizatori autentificați
    LOGGED_IN_USERS+=("$username")
    echo "Utilizatorul $username a fost autentificat."
}
# Funcție pentru deconectare
logout_user() {
    local username="$1"

    # Verificarea dacă utilizatorul este autentificat
    if ! is_user_logged_in "$username"; then
        echo "Utilizatorul $username nu este autentificat."
        return 1
    fi

    LOGGED_IN_USERS=("${LOGGED_IN_USERS[@]/$username}")
    echo "Utilizatorul $username a fost deconectat."
}

# Solicitarea acțiunii de la utilizator
while true; do
    echo "Doriți să vă autentificați sau să vă deconectați? (login/logout/exit)"
    read action
    if [ "$action" == "exit" ]; then
        echo "Ieșire din script."
        break
    fi

    echo "Introduceți numele de utilizator:"
    read username

    if [ "$action" == "login" ]; then
        echo "Introduceți parola:"
        read -s password
        authenticate_user "$username" "$password"
    elif [ "$action" == "logout" ]; then
        logout_user "$username"
    else
        echo "Acțiune necunoscută."
    fi
done
