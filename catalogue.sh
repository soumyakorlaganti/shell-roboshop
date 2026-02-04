#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
B="\e[30m"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
P="\e[35m"
C="\e[36m"
N="\e[0m"


if [ $USERID -ne 0 ]; then
    echo -e "$R please run the script with root user access $N" | tee -a &>>$LOGS_FILE
    exit1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2...$R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2...$G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disabling NodeJs Default Version"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "Enabling NodeJs 20"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Installing NodeJs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
VALIDATE $? "Creating system user"

mkdir /app  &>>$LOGS_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading catalogue code"

cd /app &>>$LOGS_FILE
VALIDATE $? "Moving to app directory"

unzip /tmp/catalogue.zip &>>$LOGS_FILE
VALIDATE $? "Unzip catalogue code"

npm install &>>$LOGS_FILE
VALIDATE $? "Installing dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload
systemctl enable catalogue  &>>$LOGS_FILE
systemctl start catalogue
VALIDATE $? "Starting and enabling catalogue"

# dnf install mongodb-mongosh -y

# mongosh --host MONGODB-SERVER-IPADDRESS </app/db/master-data.js

# mongosh --host MONGODB-SERVER-IPADDRESS



