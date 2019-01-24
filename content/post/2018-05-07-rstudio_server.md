---
title: "Deploying a secure Shiny Server and RStudio Server on a free Google Cloud virtual machine"
slug: "protected_free_shiny"
date: "2018-05-07"
---
 

I have recently had to deploy a public-facing shiny dashboard.    I decided this would be the perfect time to create my first google cloud machine.  The main reasons I decided to do it on the cloud are as follow:   
  
    * No need to open port on my home computer  
    * Guaranteed to be always on  
    * Free ( I chose a f1-micro  instance)

[This guide](https://github.com/paeselhz/RStudio-Shiny-Server-on-GCP)  by Luis Henrique Zanandrea Paese on GitHub covered all the bases I needed to covered to start my first RStudio / Shiny server.  In this post, I will complement Luis's guide with the following information that was required for my use case:  

    * Create a swap file because the f1-micro doesnt have enough ram to compile `rcpp`
    * Install dependencies for the "sf" package (GDAL was a pain)  
    * Get a static IP address   for my virtual machine
    * Link my domain name to the static IP address  using "A Record"
    * Password-protect the shiny server using nginx   

## Setting up the GCP VM instance
Here we follow Luis's instruction to create the VM instance.  I used a f1-micro instance (0.2 CPU, 512 MB RAM)  because it is free.  

EDIT: I have been recently made aware of the [googleCOmputerEngineR](https://github.com/cloudyr/googleComputeEngineR/blob/master/README.md) package, which can create a google cloud instance from your local R session.  Definitely worth a try.

## Create a swap file
I create a 3GB swap file because we don't have enough RAM to compile `rcpp` using the f1-micro instance.  [Just follow this guide](https://digitizor.com/create-swap-file-ubuntu-linux/): 
```
cd /
sudo dd if=/dev/zero of=swapfile bs=1M count=3000
sudo mkswap swapfile
sudo swapon swapfile
sudo nano etc/fstab
/swapfile none swap sw 0 0
cat /proc/meminfo
```


## Installing R, RStudio Server and Shiny Server on your virtual machine

Here we follow Luis's guide, with the only differences being a a few lines under "install spatial libraries" to make sure that a recent version of GDAL will be installed, allowing me to install the `sf` package.   

Make sure that your machine is up-to-date by running these commands:  
```
sudo apt-get update
sudo apt-get upgrade

sudo sh -c 'echo "deb https://cloud.r-project.org/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list'
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
sudo apt-get -y update && sudo apt-get -y upgrade
```

Install spatial libraries for sf , including GDAL > 2.2.0   (some black magic here, it definitely could be optimized but I don't know how)
```
sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
sudo apt-cache policy libgdal-dev
sudo  add-apt-repository -y ppa:ubuntugis/ppa
sudo apt update
sudo apt upgrade
sudo apt install gdal-bin python-gdal python3-gdal
sudo apt-get update 
sudo apt-get install libgeos-dev libproj-dev libgdal-dev libudunits2-dev libv8

```

Install R

```
sudo apt-get -y install r-base r-recommended r-base-dev libcurl4-openssl-dev build-essential libxml2-dev libssl-dev
```

Run R and install packages:
```
sudo -i R
```

```
install.packages("devtools")
install.packages(c('shiny', 'rmarkdown', 'tidyverse'))
install.packages(c('sf', 'leaflet'))
q()
```

Installing RStudio Server and Shiny Server on your virtual Machine

```
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/rstudio-server-1.1.419-amd64.deb
sudo gdebi rstudio-server-1.1.419-amd64.deb
```
We also create a username which will be used to log into RStudio
```
sudo adduser YOUR_USER_NAME
```

Install Shiny server : 
```
sudo apt-get install gdebi-core
wget https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.5.5.872-amd64.deb
sudo gdebi shiny-server-1.5.5.872-amd64.deb
```

Luis also recommends to set full edit permissions to the folder containing shiny-servers:
```
sudo chmod 777 -R /srv/shiny-server/
```

At this point, we have a running RStudio server accessible at http://your_external_ip:3838 and  a Shiny server accessible at http://your_external_ip:8787.   
We will want that IP to be static and linked to a domain name and we will both servers to be password protected.  

## Static external IP

Our VM IP address can change every time we restart it.  This means we can't point any bookmark or domain names to our servers.  Thankfully, static external addresses are free as long as the machine they are linked to is powered on.  We will leave it always on since we are using the free machine anyway.    
Following the instructiosn from this [dataquest blog post](https://www.dataquest.io/blog/setting-up-a-free-data-science-environment-on-google-cloud/),    we navigate to the google cloud console (https://console.cloud.google.com), then click on the three horizontal bars at the top-left of the page to show the "products and services" menu on the left.  Then we navigate to Networking > VPC network > External IP addresses.  Or jump to [this URL](https://console.cloud.google.com/networking/addresses).

## Pointing a domain name to our VM using "A Record"  

This is not supposed to be hard, but this took me a while to figure out because I made the mistake to ask Netfirms's technical support to help me.   They wasted 90 minutes trying to set up a "CName" and "subdomain" linking to my VM.  After some googling, I learned that Iwhat I needed was an "A record" linking to my vm's external machine IP address.   I named the record "shiny" for the rest of this example.  
  
At this point, shiny.mydomain.com:8787 links to my rstudio server and shiny.mydomain.com:3838 links to my shiny server.   

## Securing the Shiny server by hiding them behind nginx authentification

This is all great, but one of my shiny dashboards need to be kept away from the public eye.    This is where nginx, a web server, comes in.  The code below is based on the [Add Authentication to Shiny Server with Nginx blog post by Kris Eberwein](https://www.r-bloggers.com/add-authentication-to-shiny-server-with-nginx/)  and the Rstudio pages about [running rstudio server with a proxy](https://support.rstudio.com/hc/en-us/articles/200552326-Running-RStudio-Server-with-a-Proxy) and  [running shiny server with a proxy](https://support.rstudio.com/hc/en-us/articles/213733868-Running-Shiny-Server-with-a-Proxy).

```
sudo apt-get install nginx
sudo apt-get install apache2-utils
sudo service nginx stop
sudo nano /etc/nginx/nginx.conf
```
Inside the nginx.conf file, we find the line that starts with 
```
http {
```
and we add the following :
```
map $http_upgrade $connection_upgrade {
      default upgrade;
      ''      close;
    }

  server {
    listen 80;


    location /rstudio/ {
      rewrite ^/rstudio/(.*)$ /$1 break;
      proxy_pass http://localhost:8787;
      proxy_redirect http://localhost:8787/ $scheme://$host/rstudio/;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;
      proxy_read_timeout 20d;
      auth_basic "Username and Password are required"; 
      auth_basic_user_file /etc/nginx/.htpasswd;
    }



    location /shiny/ {
      rewrite ^/shiny/(.*)$ /$1 break;
      proxy_pass http://localhost:3838;
      proxy_redirect http://localhost:3838/ $scheme://$host/shiny/;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;
      proxy_read_timeout 20d;
      proxy_buffering off;
      auth_basic "Username and Password are required"; 
      auth_basic_user_file /etc/nginx/.htpasswd;
    }
    
    location /shiny-admin/ {
      rewrite ^/shiny-admin/(.*)$ /$1 break;
      proxy_pass http://localhost:4151;
      proxy_redirect http://localhost:4151/ $scheme://$host/shiny-admin/;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;
      proxy_read_timeout 20d;
      proxy_buffering off;
      auth_basic "Username and Password are required"; 
      auth_basic_user_file /etc/nginx/.htpasswd;
    }    
  } 
```
then, we rename a configuration file that we just made obsolete (or we could just comment out all of it): 
```
sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

```

Create some usernames and passwords:
```
cd /etc/nginx
sudo htpasswd -c /etc/nginx/.htpasswd exampleuser
```

Start the nginx server:
```
sudo service nginx start
```
At this point, there is a password-protected version of our shiny server at shiny.mydomain.com/shiny and a password-protected version of the rstudio server at shiny.mydomain.com/rstudio.   

However, the non-password protected version is still available at shiny.mydomain.com:3838 .  To disable it, we'll edit the shiny-server conf file:
```
sudo systemctl stop shiny-server
sudo nano /etc/shiny-server/shiny-server.conf
```

The only modification we need to do is to add "127.0.0.1" after "listen 3838", like so:  
```
server{
    listen 3838 127.0.0.1;
    
    location / {
    site_dir /srv/shiny-server;
    log_dir /var/log/shiny-server;
    directory_index on;
    }
}
```

Restart the shiny server
```
sudo systemctl start shiny-server
```










