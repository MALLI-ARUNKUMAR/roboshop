#!/bin/bash
user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/${0}.log"
direct_script=$(pwd)
domain="daws880s.online"

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
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) ${2}......${R} FAILURE ${N}"
        exit 1
    else
        echo -e "$(timestamp) ${2}......${G} SUCCESS ${N}"    
    fi    
       
}

mkdir -p $logs_folder
echo -e "$(timestamp) scripting...................starting............"

dnf module disable nodejs -y &>> $logs_file
validate $? "disabling the nodejs"

dnf module enable nodejs:24 -y &>> $logs_file
validate $? "enable the nodejs"

dnf install nodejs -y &>> $logs_file
validate $? "install the nodejs"

node -v &>> $logs_file
validate $? "to check and verify"
id roboshop &>> $logs_file
if [ $? -ne 0 ]; then
    echo "roboshop user not created creating now"
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating the roboshop user"
else
    echo " user created skipping now"
fi
mkdir -p /app &>> $logs_file
validate $? "creating the app directory"

curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip
validate $? "copying the code to temp location"

cd /app &>> $logs_file
validate $? "moving to the app directory"

rm -rf /app/* &>> $logs_file
validate $? "removing to the app directory"

unzip /tmp/catalogue.zip $logs_file
validate $? "unzip the code"

cd /app &>> $logs_file
validate $? "moving to the app directory"

npm install &>> $logs_file
validate $? "installing the dependences"

cp $direct_script/catalogue.service /etc/systemd/system/catalogue.service &>> $logs_file
validate $? "copying the catalogue services"

systemctl daemon-reload &>> $logs_file
validate $? "daemonreload"

systemctl enable catalogue &>> $logs_file
validate $? "enable the catalogue"

systemctl start catalogue &>> $logs_file
validate $? "start the catalogue"

cp $direct_script/mongo.repo /etc/yum.repos.d/mongo.repo &>> $logs_file
validate $? "copying the catalogue services"

dnf install mongodb-mongosh -y &>> $logs_file
validate $? "installing the mongodb"

index=$(mongosh --host "mongodb.$domain" --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()')
validate $? "Connecting to MongoDB"
if [ index -eq 0 ]; then
    mongosh --host "mongodb.$domain" </app/db/master-data.js
    validate $? "loading db data"
else
    echo "schemas all ready loaded skipping"
fi

dnf restart mongodb &>> $logs_file
validate $? "restarting the mongodb"



 