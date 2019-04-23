# DEPLOY SIMS CHECKPOINT WITH PACKER AND BASH SCRIPT

This giude assumes you already have an AWS account however if you do not, go to https://aws.amazon.com/ to quickly create one. After doing so, you can continue with the steps listed below.

Firstly, we use packer to create an **Amazon Machine Image (AMI)** which we would use to host our application.
## Creating AMI Image
1) Install [packer](https://packer.io/downloads.html) if not already installed.
2) After installation, verify that packer was installed by typing **packer** in your terminal. You should see an output that shows how to use packer and its available commands.
3) Create a **packer.json** file (you can name it anything you like) and write in it the configurations you want packer to use i.e: builders, provisioners, etc. For the purpose of this task, I have an already set up packer.json file. Go ahead to clone this repo and continue with the steps below.
4) You would also need to create bash scripts that you would use to provision your AMI if you want to. I have 3 bash scripts in the folder **scripts** to update my Ubuntu AMI and install some necessary packages like nodejs, certbot, pm2, etc.
5) Export your environment variables (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY) lke so: 
- `export AWS_ACCESS_KEY_ID="your_aws_access_key"`
- `export AWS_SECRET_ACCESS_KEY="your_aws_secret_key"`
6) Proceed to build your AMI with the packer.json file: `packer build packer.json`
7) At the end, if all goes well, you should see the newly created AMI in your AWS EC2 dashboard under **AMIs**

Secondly, we launch our newly created AMI to host our app.
## Setting up an EC2 instance
1) Log in to your AWS dashboard and click on the **Services** tab which would display a dropdown of several options. Click on **EC2**.
2) On the EC2 dashboard, look for a blue button that says **Launch Instance** and click on it. This would begin a dialog of options from which you would choose the one that best suits you.
3) After clicking on the **Launch Instance** button, you would be required to choose an **Amazon Machine Image (AMI)** which is like a pre-configured operating system. For the purpose of this activity, I chose the newly created AMI from the steps above. This can be found under the tab **my AMIs**.
4) Next you'd be required to choose the Instance type that you prefer. This determines the processor type and speed, memory size, etc. Choose the one which best suites you, however since I am not deploying a large scale application, I chose the **t2 micro**. Click on **next: configure instance details**.
5) In this step, you can customize details of your instance to your satisfaction or you can go ahead and leave it at the deafult values like I did. When done, click on **next: add storage**.
6) Here you can customize the amount of storage you would need depending on your application size and requirements. Go ahead and leave it in the default values if you want. Click **next: add tags**.
7) You can choose to add a tag/tags (name) to your instance or leave it if you want. Click on **next: configure security group**.
8) In this step, you configure the type of inbound and outbound traffic you want in your instance. You can specify ports that you want to accept traffic or not, you can specify Ip addresses that can access your instance, etc. If you do not have an already existing security group that suits your needs, go ahead and click on **create new security group** and then on **add rule**. For the purpose of this activity, I am adding three rules:
- type: HTTP, protocol: TCP, port: 80, source: custom
- type: Custom TCP, protocol: TCP, port: 3000, source: anywhere (this port is for my application)
- type: HTTPS, protocol: TCP, port: 443, source: custom
9) After this click on **review and launch** and then **launch** to create and start your instance. You would be asked to either create a key pair file or use an existing on. Please download and keep this file safe and secure as you cannot download it again and it is what you would use to SSH into your instance.
10) When your instance is up and running, you can access it with its public IP address. Here we see that we don't need to type the port **3000** to access our application. This is because we already have our **Nginx** configured to proxy pass http requests to the port 3000. We also see that we ddint need to SSH into our instance to start the app, it was already started. This was achieved with the help of **PM2** which starts our app in the background and makes sure it is always started and running. 

## Linking your Domain name to your instance with Route 53
Now that you can access your app through the public IP of your instance, it would be even better to have a domain name instead of an IP address. The next step is to link your domain name to your instance.
1) Go to https://console.aws.amazon.com/route53/home? to access the route 53 dashboard.
2) Click on **create hosted zone** to create a hosted zone for your domain name. Enter your domain name in the dialog to your right and click on **create**.
3) Click on the hosted zone that you just created and then click on **create record set** to create a record that would link your domain or sub-domain to your instance.
4) In the dialog to your right, enter the sub-domain that you want to link under name, e.g: `wwww`, `app.`, etc. If you do not want to link a sub-domain, just leave that field empty.
5) Under **value**, input the public IP address of your instance. It is advised to use an **elastic IP** as they do not change when your instance is stopped and restarted unlike the random public IP addresses assigned to the instance.
6) You can create as many records as you need and you can test them to ensure everything went fine.
7) Lastly, copy the **name servers** assigned to your hosted zone and put them as the **name servers** in your domain.
8) You can now access your app from your domain name, however, our site is not secure because we haven't obtained and installed SSL certificates.

## Obtaining and Installing SSL certificates.
1) To SSH (login in lay man's terms) into your instance, click on the instance in your EC2 dashboard and click on connect. Copy the command after **Example** e.g: ssh -i "path_to_pem_key_pair_file.pem" ubuntu@instance_public_dns.
2) When logged in, run this command `sudo certbot --nginx --email :exaple@yahoo.com --agree-tos --no-eff-email -d :domainname:` replacing the variables with your email and domain names that you want to install the SSL: certificates for. Choose 2 to redirect all HTTP traffic to HTTPS when prompted. 
3) After running the command, when you view your site it would be secure evident from the **https** prefix in your url.

Congratulations, you have successfully created a provisioned AMI, launched it, linked it to a domain name and installed SSL certificates for your site!!




