#!/bin/bash
PSQL="psql -U postgres -d noteapp -A -t -c"
menu(){
    if [[ $1 ]]
    then
        echo $1
    fi
    clear
    echo -e "\n~~ Not Defteri ~~\n"
    echo -e "kullanıcı adı girin:"
    read username
    if [[ -z "$username" ]]
    then
        pass=false
        until [[ $pass == true ]]
        do
            echo -e "kullanıcı adı girin:"
            read username
            if [[ -n "$username" ]]
            then
                pass=true
            fi
        done
    fi
    user_req=$($PSQL "SELECT username FROM users WHERE username = '$username'" 2>> ./logs/err.log) 
    if [[ -z $user_req ]]
    then
        echo -e "sen daha önce kayıt olmamışsın seni kaydediyorum\n"
        INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$username')")
        if [[ -n $INSERT_RESULT ]] 
        then
            date="now"
            echo yes
            log $username "creates $username on users at $date"
        fi
    else
        echo -e "hoş geldin "$username"!\n" 
    fi
    echo -e "1.Not yaz\n2.Notları gör\n3.Not sil\n4.Çıkış"
    read select
    case $select in
        1)add_note;;
        2)see_notes;;
        3)delete_note;;
        4)exit;;
        *)menu geçersiz;;
    esac
}
log(){
    if [[ $1 && $2 ]]
    then
        echo "$2" 1>> "./logs/$1.log"
    fi
}
add_note(){
    menu
}
see_notes(){
    menu
}
delete_note(){
    menu
}
exit(){
    echo -e "end of the session of..."
}

menu

