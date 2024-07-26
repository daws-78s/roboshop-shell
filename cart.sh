#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGO_HOST=mongodb.daws78s.online

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

dnf module enable nodejs:20 -y &>> $LOGFILE
VALIDATE $? "Enabling nodejs:20"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing NodeJS"

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Adding roboshop user"
else
    echo -e "roboshop user already exist...$Y SKIPPING $N"
fi

rm -rf /app &>> $LOGFILE
VALIDATE $? "clean up existing directory"

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "downloading cart application"

cd /app  &>> $LOGFILE
VALIDATE $? "Moving to app directory"

unzip /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "extracting cart"

npm install &>> $LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reload"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "Enable cart"

systemctl start cart &>> $LOGFILE
VALIDATE $? "Start cart"