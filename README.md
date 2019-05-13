# DEPLOY SIMS CHECKPOINT WITH PACKER AND BASH SCRIPT

This guide assumes you already have an AWS account however if you do not, go to `https://aws.amazon.com/` to quickly create one. After doing so, you can continue with the steps listed below.

N/B: If you haven’t purchased a `domain name`, proceed to do so now or you can visit freenom to register a free one. 

Firstly, we use **packer** to create an **Amazon Machine Image (AMI)** which we would use to host our application.
## Creating AMI Image
1) Install [packer](https://packer.io/downloads.html) if not already installed.
2) After installation, verify that `packer` was installed by typing **packer** in your terminal. You should see an output that shows how to use packer and its available commands.
3) Proceed to create a **packer.json** file (you can name it anything you like) and write in it the configurations you want packer to use i.e: builders, provisioners, etc. A **packer.json** file is a configuration file where we list the builder configurations (what packer would use to build the AMI) and the provisioner configurations (what packer would use to provision the AMI). For the purpose of this task, I have an already set up packer.json file. **Go ahead to clone this repo** by running `git clone https://github.com/primuse/output2.1.git` and continue with the steps below.
4) You would also need to create **bash scripts** that you would use to provision your AMI if you want to. I have 3 descriptive bash scripts in the folder scripts to update my Ubuntu AMI and install some necessary packages like nodejs, certbot, pm2, etc, clone the repo where my app is hosted and start it and then configure nginx as a reverse proxy.
Please replace the domain names in the nginx configuration with your domain and subdomain names. i.e:
```
server {
    listen 80;
    server_name localhost sendit-ah.gq www.sendit-ah.gq;
    location / {
        proxy_pass http://127.0.0.1:3000;
    }
}
```
Replace `sendit-ah.gq` and `www.sendit-ah.gq` in the block above with your own domain and subdomain names.

- [PM2](https://www.npmjs.com/package/pm2) is a process manager for the JavaScript runtime Node.js. It allows you to keep applications alive forever, to reload them without downtime and to facilitate common system admin tasks. I chose this because my application is written with nodeJs and javascript.
- [Let’s Encrypt](https://letsencrypt.org/) is designed to provide free, automated, and open security certificate authority (CA) for everyone. It enables website owners to get security certificates within minutes.
- [Certbot](https://certbot.eff.org/) automatically enables HTTPS on your website with EFF's Certbot, deploying Let's Encrypt certificates.
- [Nginx](https://www.linode.com/docs/web-servers/nginx/use-nginx-reverse-proxy/) A reverse proxy is a server that sits between internal applications and external clients, forwarding client requests to the appropriate server. While many common applications, such as Node.js, are able to function as servers on their own, NGINX has a number of advanced load balancing, security, and acceleration features that most specialized applications lack. Using NGINX as a reverse proxy enables you to add these features to any application.

5) Proceed to export your AWS **access key ID** and **secret access key** as environment variables. When building **AWS AMIs**, Packer needs these credentials to authenticate the AWS account you want to build the AMI for. If these are not provided, packer would throw an error and your AMI would not be built. 

   For this task, I provided these credentials as environment variables and so you would need to provide yours as well. To get these credentials (if you don't have them), proceed to your [AWS dashboard](https://aws.amazon.com/), click on the **dropdown (with your account name)** on the top right corner of the screen and then click on **My security credentials**. This would take you to a page with various settings for your security credentials. Click on the **Access keys (access key ID and secret access key)** tab and then click on **Create New Access Key**. This would create new credentials for you; please **download** the credential file and place it in a **secure place**. __It would not be available for download again__.

   Export your environment variables (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) like so: 
- `export AWS_ACCESS_KEY_ID="your_aws_access_key"`
- `export AWS_SECRET_ACCESS_KEY="your_aws_secret_key"`

6) Proceed to build your AMI with the packer.json file by running the command: `packer build packer.json`
7) In the end, if all goes well, you should see the newly created AMI in your AWS EC2 dashboard under **AMIs**

Secondly, we launch our newly created AMI to host our app.
## Setting up an EC2 instance
1) To set up your EC2 instance, log in to your **AWS dashboard** and click on the **Services** tab which would display a dropdown of several options. Click on **EC2**.
2) On the EC2 dashboard, look for a blue button that says **Launch Instance** and click on it. This would begin a dialog of options from which you would choose the one that best suits you.
3) After clicking on the **Launch Instance** button, you would be required to choose an **Amazon Machine Image (AMI)** which is like a pre-configured operating system. For the purpose of this activity, I chose the new AMI I created from the steps above. This can be found under the tab **my AMIs**.
4) Next, you'd be required to choose the Instance type that you prefer. This determines the processor type and speed, memory size, etc. Choose the one which best suits you, however since I am not deploying a large scale application, I chose the **t2 micro**. Click on **next: configure instance details**.
5) Proceed to customize details of your instance to your satisfaction or you can go ahead and leave it at the default values as I did. When done, click on **next: add storage**.
6) Here you can customize the amount of storage you would need depending on your application size and requirements. Go ahead and leave it in the default values if you want. Click **next: add tags**.
7) You can choose to add a **tag/tags** (name) to your instance or leave it if you want. Click on **next: configure security group**.
8) Proceed to configure the type of inbound and outbound traffic you want in your instance. You can specify **ports** that you want to accept traffic or not, you can specify **Ip addresses** that can access your instance, etc. If you do not have an already existing security group that suits your needs, go ahead and click on **create new security group** and then on **add rule**. For the purpose of this activity, I am adding three rules:
- **type:** `HTTP`, **protocol:** `TCP`, **port**: `80`, **source:** `custom`- which means to **allow HTTP traffic on port 80**.
- **type:** `Custom TCP`, **protocol:** `TCP`, **port:** `3000`, **source:** `anywhere` (this port is for my application)- which means to **allow traffic on port 3000**.
- **type:** `HTTPS`, **protocol:** `TCP`, **port:** `443`, **source:** `custom`- which means to **allow HTTPS traffic on port 443**.

9) Proceed to create and start your instance by clicking on **review and launch** and then **launch**. You would be asked to either create a **key pair file** or **use an existing one**. **N/B:** *Please download and keep this file safe and secure as you cannot download it again and it is what you would use to SSH into your instance*.

10) When your instance is up and running, you can access it with its **public IP address**. Here we see that we don't need to type the port `3000` to access our application. This is because we already have our **Nginx** configured to proxy pass HTTP requests to the port `3000`. We also see that we didn't need to SSH into our instance to start the app, it was already started. This was achieved with the help of **PM2** which starts our app in the background and makes sure it is always started and running. 

## Linking your Domain name to your instance with Route 53
Now that you can access your app through the public IP of your instance, it would be even better to have a domain name instead of an IP address. The next step is to link your domain name to your instance. We achieve this using **AWS Route 53**.
1) Go to `https://console.aws.amazon.com/route53/home?` to access the **Route 53** dashboard.
2) Click on **create hosted zone** to create a hosted zone for your domain name. Enter your **domain name** in the dialog to your right and click on **create**. 
[Amazon](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/AboutHZWorkingWith.html) describes a public hosted zone as:

   > a container that holds information about how you want to route traffic on the internet for a **specific domain**, such as `example.com`, and its **subdomains** (`acme.example.com`, `zenith.example.com`)- [Amazon](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/AboutHZWorkingWith.html)
3) After creating a **hosted zone** for your domain, such as `example.com`, you create records to tell the **Domain Name System (DNS)** how you want traffic to be routed for that domain. To do this, click on the **hosted zone** that you just created and then click on **create record set** to create a record that would link your `domain` or `sub-domain` to your instance.
4) In the dialog to your right, enter the `sub-domain` that you want to link to your instance under **name**, e.g: `wwww`, `app.`, etc. If you do not want to link a `sub-domain`, just leave that field empty.
5) Under **value**, input the **public IP address** of your instance. It is advised to use an **elastic IP** as they do not change when your instance is stopped and restarted unlike the random public IP addresses assigned to the instance by AWS.
*N/B: You can create as many records as you need.*
6) Lastly, copy the **name servers** assigned to your hosted zone and put them as the **name servers** in your domain. To find the AWS assigned Name servers for your hosted zone, click on the **hosted zone** you just created. The name servers are the values prefixed with `ns`; e.g: `ns-751.awsdns-29.net`. A **name server** is any server which has **DNS** installed on it. **DNS**, or the **Domain Name System**, converts domain names (for example, `www.amazon.com`) to **IP addresses** (for example, 192.0.2.53).

   *The process of changing the name servers of your domain varies depending on the domain name registrar you're using. You can do a google search on how to go about this for your specific domain registrar.*

7) You can now access your app from your domain name e.g: `sendit.gq` by typing it in your browser address bar and clicking enter. However, our site is not secure because we haven't obtained and installed SSL certificates.

## Obtaining and Installing SSL certificates.
1) To SSH (login in lay man's terms) into your instance, click on the instance in your EC2 dashboard and click on **connect**. Copy the command after **Example** e.g: `ssh -i "path_to_pem_key_pair_file.pem" ubuntu@INSTANCE_PUBLIC_DNS`.
2) When logged in, proceed to install **SSL certificates** by running this command 

   `sudo certbot --nginx --email EXAMPLE@YAHOO.COM --agree-tos --no-eff-email -d DOMAINNAME`

   replacing the variables **EXAMPLE@YAHOO.COM** and **DOMAINNAME** with your **email** and the **domain names** that you want to install the SSL certificates for. 
   
   When prompted, choose **2** to redirect all **HTTP traffic to HTTPS**. **N/b: the variables to be substituted are in capital letters.**

3) After running the command, when you view your site it would be secure evident from the **https** prefix in your URL.

Congratulations, you have successfully created a provisioned AMI, launched it, linked it to a domain name and installed SSL certificates for your site!!




