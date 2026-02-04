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
    echo -e "$R please run the script with root user access $N" | tee -a &>> $LOGS_FILE
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

dnf module disable nodejs -y
VALIDATE $? "Disabling NodeJs Default Version"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling NodeJs 20"

dnf install nodejs -y
VALIDATE $? "Installing NodeJs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Creating system user"

mkdir /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Downloading catalogue code"

cd /app 
VALIDATE $? "Moving to app directory"

unzip /tmp/catalogue.zip
VALIDATE $? "Unzip catalogue code"

npm install 
VALIDATE $? "Installing dependencies"

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "Starting and enabling catalogue"

# dnf install mongodb-mongosh -y

# mongosh --host MONGODB-SERVER-IPADDRESS </app/db/master-data.js

# mongosh --host MONGODB-SERVER-IPADDRESS



