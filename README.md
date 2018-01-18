Subscription
============

Simple subscription API which connects to billing gateway API  


Prerequests
-----------
Ruby: ruby-2.3.3  
Ruby on Rails: 5.1.4  
Node.js  
PostgreSQL

System
------
Linux, Mac OS


Instructions for Linux
----------------------
These instructions will get you a copy of the project up and running on your local machine for testing and development purposes.

```
# install prerequests
---
# instal nodejs
sudo apt-get install nodejs

# fetch mpapis public key 
gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
# or if it fails:
command curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -

# instal latest stable rails version which will also pull in the associated latest stable release of Ruby with rvm
cd /tmp
curl -sSL https://get.rvm.io -o rvm.sh
cat /tmp/rvm.sh | bash -s stable --rails
---

# clone repository
git clone https://github.com/vistiria/subscription
cd subscription/

# source the rvm scripts from the directory they were installed, which will typically be in your home/username directory
source ~/.rvm/scripts/rvm

# install ruby
rvm install ruby-2.3.3

# install dependencies
gem install bundler
bundle install

# create a self-signed Certificate in home directory
export SSL_CERT_FILE=/path/to/ca.pem
export SSL_CERT_FILE=/home/path/ca.pem
cd ~/
mkdir .ssl
openssl req -new -newkey rsa:2048 -sha1 -days 365 -nodes -x509 -keyout .ssl/localhost.key -out .ssl/localhost.crt

# go to application path, create database and run application
cd subscription/
bin/rake db:create db:schema:load
bundle exec thin start -p 3001 --ssl --ssl-key-file ~/.ssl/localhost.key --ssl-cert-file ~/.ssl/localhost.crt

# run billing application from lib/billing_gateway
cd lib/billing_gateway/
bundle install
ruby main.rb
```

How it works
------------

Example provided with curl.  
To include the HTTP-header in the output, use the -i option.  
If you'd like to turn off curl's verification of the certificate, use the -k option.  

Register with email, password, first name, last name and credit card number:  
```
curl -i -k --header "Content-Type: application/json" --request POST --data '{  "password": "test001_password", "email": "test001@gmail.com", "first_name": "Iva", "last_name": "Novak", "card_number": "4485057923557660"}' https://localhost:3001/auth/
```
result:
```
{"status":"success","data":"user has been created, please sign in"}
```
  
Sign in with email and password:  
```
curl -i -k --header "Content-Type: application/json" --request POST --data '{  "email": "test001@gmail.com","password": "test001_password"}' https://localhost:3001/auth/sign_in
```
result:
```
{"status":"success"}
```
  
Create subscription, you will be charged 100$ per month.  
Copy access-token, client, uid, and expiry from the last response HTTP-header, and paste them to the following request:  
```
curl -i -k -H "Content-Type: application/json" -H "access-token: OfsE90MgKCvYviqhe2ghYg" -H "client: 1v4h0wgm9aAhAwJsKhNkvA" -H "expiry: 1517174947" -H "uid: test001@gmail.com" --request POST https://localhost:3001/create_monthly_subscription
```
results:
```
{"status":"success","data":"subscription created"}
{"status":"error","errors":"insufficient funds"}
{"status":"error","errors":"subscription already exists"}
{"status":"error","errors":"subscription failed, could not connect to billing service"}
```
  
You can list all valid subscriptions and next billing date.  
Copy access-token, client, uid, and expiry from the last response HTTP-header, and paste them to the following request:  
```
curl -i -k -H "Content-Type: application/json" -H "access-token: gM4Eu9CI00nf2WPu6Wyp2w" -H "client: 1v4h0wgm9aAhAwJsKhNkvA" -H "expiry: 1517250555" -H "uid: test001@gmail.com" --request GET https://localhost:3001/subscription_list
```
results:
```
{"subscription_dates":["2018-01-18"],"next_billing_date":"2018-02-18"}
{"status":"error","errors":"subscription doesn't exist"}
```
  
Sign out  
Copy access-token, client, uid, and expiry from the last response HTTP-header, and paste them to the following request:  
```
anna@rail:~/subscription1/subscription1$ curl -i -k -H "Content-Type: application/json" -H "access-token: rEAGtw1FVtXKzkDtbXC7Kw" -H "client: 1v4h0wgm9aAhAwJsKhNkvA" -H "expiry: 1517270643" -H "uid: test001@gmail.com" --request DELETE https://localhost:3001/auth/sign_out
```
result:
```
{"success":true}
```

Charging
--------

There is scheduled rake task that is executed everyday at 7:00 am. Check config/schedule.rb  
to make sure that the application path, and environment are set correctly.  
Task is responsibe for executing monthly payments and scheduling dates of next payment.

After updating config/schedule.rb, run command from application path:
```
whenever --update-crontab
```
To see cron syntax, run:
```
whenever
```
rake task could also be run manually from application path:
```
bundle exec rake subscriptions:payment
```


How to run tests
----------------
```
bundle exec rspec
```