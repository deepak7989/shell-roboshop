#!/bin/bash

LOG_FOLDER="/var/log/roboshop" #creating folder #in this folder mongodb.sh will be created
sudo mkdir -p $LOG_FOLDER #inside var/log
sudo chown -R ec2-user:ec2-user $LOG_FOLDER # Set permission to ec2-user
sudo chmod -R 755 $LOG_FOLDER
LOGS_FILE="$LOG_FOLDER/$0.log"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.deep90s.online

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

dnf install python3 gcc python3-devel -y &>> $LOGS_FILE
VALIDATE $? "Installing Python"

id roboshop &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop alredy created ... $Y SKIPPING $N"
fi

rm -rf /app
VALIDATE $? "Removing existing code"

rm -rf /tmp/payment.zip
VALIDATE $? "Removed payment zip"

mkdir -p /app &>> $LOGS_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>> $LOGS_FILE
cd /app 
unzip /tmp/payment.zip &>> $LOGS_FILE
VALIDATE $? "Dowloaded and extracted payment code"

pip3 install -r requirements.txt &>> $LOGS_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Created systemctl service"

systemctl enable payment 
systemctl restart payment
VALIDATE $? "Enable and restarted payment"