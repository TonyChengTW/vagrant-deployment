#!/usr/bin/expect -f 
#set username $env(UNAME) 
#set password $env(UPASS) 
set username root
set password fhrootroot
spawn passwd $username 
expect "New password:" 
send "$password\r" 
expect "Re-enter new password:" 
send "$password\r" 
send "exit\r" 
expect eof
