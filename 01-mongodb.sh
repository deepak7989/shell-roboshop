#!/bin/bash

LOG_FOLDER="/var/log/roboshop" #creating folder #in this folder mongodb.sh will be created
sudo mkdir -p $LOG_FOLDER #inside var/log
sudo chown -R ec2-user:ec2-user $LOG_FOLDER # Set permission to ec2-user
sudo chmod -R 755 $LOG_FOLDER
LOGS_FILE="$LOG_FOLDER/$0.log"

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

if [ $USERID -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR] $R Please run this script with root access $N" | tee -a $LOGS_FILE
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$TIMESTAMP [INFO] $2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo"

dnf install mongodb-org -y &>> $LOGS_FILE
VALIDATE $? "Installing MongoDB"

systemctl enable --now mongod
VALIDATE $? "Starting and enabling MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connection to MongoDB"

systemctl restart mongod
VALIDATE $? "Restarting MongoDB"