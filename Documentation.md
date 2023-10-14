# Deployment 5

## Purpose 

## Diagram

![Deployment5 drawio (2)](https://github.com/Sameen-k/Deployment5/assets/128739962/ac950fb8-1bf4-4e78-8fa4-22d1257cea9b)


## Steps 

#### Terraform: 
As shown in the diagram above, in this deployment we will be using 3 total EC2s. One EC2 will be used to launch the other two EC2s using Terraform.
Within the Terraform file be sure to configure the creation of a VPC, 2EC2s that exist in two different public subnets which exist within 2 different availability zones (us-east-1a, us-east-1b). Make sure to also configure an Internet gateway. When configuring a route table, be sure to use the following resource block:

``resource "aws_default_route_table"``

This is to ensure that Terraform knows to utilize the default route table it will originally create to route the VPC, public subnets, and internet gateway for all associations.
For the VPC the CIDR block was 10.0.0.0/16. All the network IPs will now fall within this range.

Make sure to also configure a security group that includes ingress traffic from ports 8080, 8000, and 22 as well as all egress traffic.
Please refer to the main.tf file within this repository for the exact configurations. Make sure to put any access and secret keys in a variable for security purposes.
The main.tf file also uses a Jenkins script that's used to install jenkins upon launch of instance 1. Through out the documentation, the instance with Jenkins will be called instance 1 (Jenkins) and the instance that will have the application launched into it will be referred to instance 2 (Application). 

<img width="1159" alt="Screen Shot 2023-10-14 at 1 41 58 AM" src="https://github.com/Sameen-k/Deployment5/assets/128739962/11de3bf4-83c6-4dce-b052-b0900a0089d9">

*This is what the connections should look like on AWS*

#### Configuring SSH:
After you have your infrastructure running, you have to make sure that you can make an SSH connection between both instances terraform created. In order to do this you must go into instance 1 (Jenkins) and sign into your Jenkins user. To do this, run the following command:

``sudo su - jenkins -s /bin/bash``

after this generate a public key by doing the following command:

``ssh-keygen``

After generating the public key, the output of the command will also indicate the path to where that key is located.

![jssh-keygen copy](https://github.com/Sameen-k/Deployment5/assets/128739962/9f9ab57a-665c-4745-b427-d9b327d35b1b)

To access the key that was just created, just cat to the file where the key was just created.

``cat /var/lib/jenkins/.ssh/id_rsa.pub``

On instance 2 (Application) you just need to copy and paste the key that was just generated in instance 1 (Jenkins) into the authorized_keys file on instance 2 (Application)
To do this, on the terminal of instance 2 (Application) 
cd to ssh directory:

``cd .ssh``

then open to edit the authorized_keys file and paste the key into this file and save:

``sudo nano authorized_keys``

After this, you can test your ssh connection. On instance 1 (Jenkins) ssh into instance 2 (Application) from the Jenkins user. 

``ssh ubuntu@<ipaddress>``

Then you can test transferring files as well. On your instance 1 (Jenkins) in your Jenkins user, create a test file. Then run the following command 

``scp test.txt ubuntu@<ipaddress>:/home/ubuntu``

Then check instance 2 (Application) if test.txt appears in the /home/ubuntu directory. If yes, you've sufficiently tested your ssh connection!

#### Installations:
On instance 1 (Jenkins) make sure you have the following packages to be able to run the applcition build. In the ubuntu user, install the following: 
``sudo apt install -y software-properties-common`` ``sudo add-apt-repository -y ppa:deadsnakes/ppa`` ``sudo apt install -y python3.7`` ``sudo apt install -y python3.7-venv``

On instance 2 (Application) make sure you have the following packages to be able to run the applcition. Install the following: ``sudo apt install -y software-properties-common`` ``sudo add-apt-repository -y ppa:deadsnakes/ppa`` ``sudo apt install -y python3.7`` ``sudo apt install -y python3.7-venv``

#### Jenkins file Additions:
In this deployment there are 3 essential scripts that are used for this application to run efficiently. They are utilized within the Jenkins files to be run on instance 2 (Application). This way the application can be deployed and setup in the second instance. 

First we need to know where Jenkins is storing the files it will be utilizing. To do this we can configure Jenkins on instance 1 (Jenkins) and even run Jenkinsfilev1 build. This way we can locate the path Jenkins uses. 
On the terminal of instance 1 (Jenkins) make sure to log into your Jenkins user. Then run the following command:

``Find -name <setup.sh>``

This is a command to search for a particular file. You can pick any file that appears in your repository that you connected to Jenkins. I chose to search for setup.sh. 

![Chrome File Edit View History Bookmarks Profiles Tab Window Help copy](https://github.com/Sameen-k/Deployment5/assets/128739962/e2c67fe1-8bde-4bc5-a56d-05421b645332)

As highlighted in the screenshot above, I was able to locate where Jenkins was storing its files. 

``./var/lib/jenkins/workspace/dep5_main/``

This path is essential for the following steps

To run the scripts on instance 2 (Application), we need to add a command to ssh into instance 2 (Application) from instance 1 (Jenkins) as well as secure copy paste (scp) the necessarry setup script. To do this, in Jenkinsfilev1 we can add the following lines to the deploy stage 

<img width="658" alt="Screen Shot 2023-10-14 at 3 18 51 AM" src="https://github.com/Sameen-k/Deployment5/assets/128739962/0464a394-1afe-4f45-83c8-c248d3a9d9fc">


Then to the clean stage in Jenkinsfilev2 we can add the following changes to scp the pkill.sh script (Application)

<img width="625" alt="Screen Shot 2023-10-14 at 3 18 39 AM" src="https://github.com/Sameen-k/Deployment5/assets/128739962/f2a058dd-fb5d-48e0-8cdf-4c23d5c22cdf">


Then to the deploy stage in the Jenkinsfilev1 we can add the following changes to scp the setup2.sh script in instance 2 (Application)

<img width="632" alt="Screen Shot 2023-10-14 at 3 18 26 AM" src="https://github.com/Sameen-k/Deployment5/assets/128739962/40b85726-4c19-4190-9b96-e55a45b3d0a4">

Then 
