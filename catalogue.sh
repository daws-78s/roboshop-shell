#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling current nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling nodejs:20"

dnf install nodejs -y
VALIDATE $? "Installing NodeJS"

useradd roboshop
VALIDATE $? "Adding roboshop user"

mkdir /app
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "downloading catalogue application"

cd /app 
VALIDATE $? "Moving to app directory"

unzip /tmp/catalogue.zip
VALIDATE $? "extracting catalogue"

npm install 
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload
VALIDATE $? "Daemon reload"

systemctl enable catalogue
VALIDATE $? "Enable catalogue"

systemctl start catalogue
VALIDATE $? "Start catalogue"