#!/bin/bash
user_id=$(id -u)
logs_folder="var/log/roboshop"
log_file="$logs_folder/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $user_id -ne 0 ]; then
        echo "this user is not root user run the script with the root user"
        exit 1
fi
timestamp() {
    date "+%F %T"
}
validate () {
    if [ $1 -ne 0]; then
        echo -e "$(timestamp) ${2}......${R} FAILURE ${N}"
    else
        echo -e "$(timestamp) ${2}......${G} SUCCESS ${N}"    
    fi    
       
}

mkdir -p $logs_folder


echo -e "$(timestamp) scripting...................starting............"
cp mongo.repo /etc/yum.repos.d/mongo.repo 
validate $? "coping the mongo repo"

dnf install mongodb-org -y &>> $log_file
validate $? "installing the mongodb"

systemctl enable mongod &>> $log_file
systemctl start mongod &>> $log_file
validate $? "start and enable the mongod"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $log_file
validate $? "enabling the remote access"

systemctl restart mongod &>> $log_file
validate $? "restarting the mongod"

 echo -e "$(timestamp) scripting...................completed  $(SECONDS)............"