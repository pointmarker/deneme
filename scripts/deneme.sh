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
            USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$username'")
        fi
    else
        echo -e "\nhoş geldin "$username"!\n" 
        USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$username'")
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
add_note(){
    history+=("add_note")
    clear
    echo -e "notunuzu ekleyin:"
    read note
    echo -e "\ngrubu var mı: (maks 30 karakter)"
    read group
    while [[ ${#group} -gt 30 ]]
    do
        echo -e "\n(maks 30 karakter,tekrar gir)"
        read group
    done
    local level=""
    local action="note_added"
    LOG_ID=$($PSQL "INSERT INTO logs(user_id, log, log_group) VALUES($USER_ID,'$action','$level ) RETURNING log_id;")
    NOTE_INSERT=$($PSQL "INSERT INTO notes(user_id, note, group_name,log_id) VALUES($USER_ID,'$NOTE','$group',$LOG_ID);")
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
    groups=$($PSQL "SELECT group_name FROM notes WHERE user_id = '$USER_ID'")
    echo $groups
    alternate_menu
}
delete_note(){
    echo "delete"
}
exit(){
    echo -e "\ngörüşürüz $username"
}

menu

