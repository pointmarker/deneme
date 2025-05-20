#!/bin/bash
PSQL="psql -U postgres -d noteapp -A -t -c"
history=("menu")
menu(){
    if [[ $1 ]]
    then
        echo $1
    fi
    clear
    echo -e "\n~~ Not Defteri ~~\n"
    echo -e "kullanıcı adı girin:"
    read username
    while [[ -z "$username" ]]
    do
        echo -e "kullanıcı adı girin:"
        read username
    done
    user_req=$($PSQL "SELECT username FROM users WHERE username = '$username'" 2>> ./logs/err.log) 
    if [[ -z $user_req ]]
    then
        echo -e "\nsen daha önce kayıt olmamışsın seni kaydediyorum\n"
        INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$username')")
        if [[ -n $INSERT_RESULT ]] 
        then
            local now=$(date)
            echo yes
            log $username "creates $username on users at $now"
        fi
    else
        echo -e "\nhoş geldin "$username"!\n" 
    fi
    history+=("menu")
    echo -e "1.Not yaz\n2.Notları gör\n3.Not sil\n4.Geri\n5.Çıkış\n"
    read select
    case $select in
        1)add_note;;
        2)see_notes;;
        3)delete_note;;
        4)go_back;;
        5)exit;;
        *)menu geçersiz;;
    esac
}
go_back(){
    if [[ ${#history[@]} -ge 2 ]]
    then
        func=${history[-2]}
        unset 'history[-1]'
        history=("${history[@]}")
        $func
    else
        echo -e "geri gidecek yer yok"
        sleep 2
        menu
    fi
}
log(){
    local user=${1-}
    local level=${2-}
    local action=${3-}
    local now = $(date)
    local file=".logs/$user-log.json"

    if [[ ! -f "$file" ]]
    then
        echo "[]" > "$file"
    fi

    head -c -1 "$file" > "${file}.tmp"

    if [[ $(wc -c < "${file}.tmp") -le 2 ]]
    then
        echo -n "[{\"timestamp\":\"$now\",\"level\":\"$level\",\"action\":\"$action\",\"message\":\"$message\"}]" > "$file"
    else 
        echo -n ",{\"timestamp\":\"$now\",\"level\":\"$level\",\"action\":\"$action\",\"message\":\"$message\"}]" >> "${file}.tmp"
        mv "${file}.tmp" "$file"
    fi
}
add_note(){
    history+=("add_note")
    clear
    echo -e "notunuzu ekleyin:"
    read note
    echo -e "\ngrubu var mı:"
    read group
    local now=$(date)
    log $username "$now -- $group -- $note"
    echo -e "başarılı!\n"
    alternate_menu
}

alternate_menu(){
    if [[ $1 ]]
    then
        echo -e "\n$1"
    else
    echo -e "1.Geri\n2.Menu\n3.Çıkış\n"
    read answer
    case $answer in
        1)go_back;;
        2)menu;;
        3)exit;;
        *)alternate_menu "nası yani??";;
    esac
    fi
}

see_notes(){
    history+=("see_notes")
    alternate_menu
}
delete_note(){
    echo "delete"
}
exit(){
    echo -e "\ngörüşürüz $username"
}

menu

