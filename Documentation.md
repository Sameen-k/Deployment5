# Deployment 5

## Purpose 

The purpose of this deployment was to create a terraform file that automatically creates the necessary infrastructure to build test and deploy an application on two separate EC2s. This deployment also allows developers to create a multibranch pipeline in Jenkins which runs two Jenkins files that both SSH and SCP scripts from one EC2 to the other. 

## Diagram

![Deployment5 drawio (2)](https://github.com/Sameen-k/Deployment5/assets/128739962/ac950fb8-1bf4-4e78-8fa4-22d1257cea9b)


## Steps 

#### Terraform: 
As shown in the diagram above, in this deployment we will be using 3 total EC2s. One EC2 will be used to launch the other two EC2s using Terraform.
Within the Terraform file be sure to configure the creation of a VPC, 2EC2s that exist in two different public subnets which exist within 2 different availability zones (us-east-1a, us-east-1b). Make sure also to configure an Internet gateway. When configuring a route table, be sure to use the following resource block:

``resource "aws_default_route_table"``

This is to ensure that Terraform knows to utilize the default route table it will originally create to route the VPC, public subnets, and internet gateway for all associations.
For the VPC the CIDR block was 10.0.0.0/16. All the network IPs will now fall within this range.

Ensure to also configure a security group that includes ingress traffic from ports 8080, 8000, and 22 and all egress traffic.
Please refer to the main.tf file within this repository for the exact configurations. Make sure to put any access and secret keys in a variable for security purposes.
The main.tf file also uses a Jenkins script that's used to install Jenkins upon launch of instance 1. Throughout the documentation, the instance with Jenkins will be called instance 1 (Jenkins) and the instance that will have the application launched into it will be referred to as instance 2 (Application). 

<img width="1159" alt="Screen Shot 2023-10-14 at 1 41 58 AM" src="https://github.com/Sameen-k/Deployment5/assets/128739962/11de3bf4-83c6-4dce-b052-b0900a0089d9">

*This is what the connections should look like on AWS*

#### Configuring SSH:
After you have your infrastructure running, you have to make sure that you can make an SSH connection between both instances Terraform created. In order to do this you must go into instance 1 (Jenkins) and sign into your Jenkins user. To do this, run the following command:

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

After this, you can test your SSH connection. On instance 1 (Jenkins) ssh into instance 2 (Application) from the Jenkins user. 

``ssh ubuntu@<ipaddress>``

Then you can test transferring files as well. On your instance 1 (Jenkins) in your Jenkins user, create a test file. Then run the following command 

``scp test.txt ubuntu@<ipaddress>:/home/ubuntu``

Then check instance 2 (Application) if test.txt appears in the /home/ubuntu directory. If yes, you've sufficiently tested your ssh connection!

#### Installations:
On instance 1 (Jenkins) make sure you have the following packages to be able to run the application build. In the Ubuntu user, install the following: 
``sudo apt install -y software-properties-common`` ``sudo add-apt-repository -y ppa:deadsnakes/ppa`` ``sudo apt install -y python3.7`` ``sudo apt install -y python3.7-venv``

On instance 2 (Application) make sure you have the following packages to be able to run the application. Install the following: ``sudo apt install -y software-properties-common`` ``sudo add-apt-repository -y ppa:deadsnakes/ppa`` ``sudo apt install -y python3.7`` ``sudo apt install -y python3.7-venv``

#### Jenkins file Additions:
In this deployment, 3 essential scripts are used for this application to run efficiently. They are utilized within the Jenkins files to be run on instance 2 (Application). This way the application can be deployed and set up in the second instance. 

First, we need to know where Jenkins is storing the files it will be utilizing. To do this we can configure Jenkins on instance 1 (Jenkins) and even run Jenkinsfilev1 build. This way we can locate the path Jenkins uses. 
On the terminal of instance 1 (Jenkins) make sure to log into your Jenkins user. Then run the following command:

``Find -name <setup.sh>``

This is a command to search for a particular file. You can pick any file that appears in your repository that you connected to Jenkins. I chose to search for setup.sh. 

![Chrome File Edit View History Bookmarks Profiles Tab Window Help copy](https://github.com/Sameen-k/Deployment5/assets/128739962/e2c67fe1-8bde-4bc5-a56d-05421b645332)

As highlighted in the screenshot above, I was able to locate where Jenkins was storing its files. 

``./var/lib/jenkins/workspace/dep5_main/``

This path is essential for the following steps

To run the scripts on instance 2 (Application), we need to add a command to ssh into instance 2 (Application) from instance 1 (Jenkins) as well as secure copy-paste (scp) the necessary setup script. To do this, in Jenkinsfilev1 we can add the following lines to the deploy stage 

<img width="658" alt="Screen Shot 2023-10-14 at 3 18 51 AM" src="https://github.com/Sameen-k/Deployment5/assets/128739962/0464a394-1afe-4f45-83c8-c248d3a9d9fc">


Then to the clean stage in Jenkinsfilev2, we can add the following changes to scp the pkill.sh script (Application)

<img width="625" alt="Screen Shot 2023-10-14 at 3 18 39 AM" src="https://github.com/Sameen-k/Deployment5/assets/128739962/f2a058dd-fb5d-48e0-8cdf-4c23d5c22cdf">


Then to the deploy stage in the Jenkinsfilev1, we can add the following changes to scp the setup2.sh script in instance 2 (Application)

<img width="632" alt="Screen Shot 2023-10-14 at 3 18 26 AM" src="https://github.com/Sameen-k/Deployment5/assets/128739962/40b85726-4c19-4190-9b96-e55a45b3d0a4">

After these changes to the Jenkins file, you can run a multi-branch pipeline on Jenkins by running Jenkinsfilev1. This should launch your application. Using the public IP address of instance 2 (application) ending with port 8000 you should be able to access the application

![Screen Shot 2023-10-13 at 8 29 11 PM](https://github.com/Sameen-k/Deployment5/assets/128739962/d8c39791-5fcf-490e-b491-3ec8dd762c88)

![Screen Shot 2023-10-13 at 8 29 04 PM](https://github.com/Sameen-k/Deployment5/assets/128739962/79c35632-3612-425a-9787-0f5b43ef0f7f)

This is what the application home page looks like. 

#### HTML Change
At this point, we're going to test the build by making a change to the HTML file 

![Screen Shot 2023-10-13 at 8 41 47 PM](https://github.com/Sameen-k/Deployment5/assets/128739962/e2271024-a77d-4d5f-a642-8b094d225067)

I decided to change the welcome paragraph text color to red. After running Jenkinsfilev2 in Jenkins. The change was reflected. 

![Screen Shot 2023-10-13 at 9 47 36 PM](https://github.com/Sameen-k/Deployment5/assets/128739962/f012569e-db5b-4589-8625-da0869ff3b1a)

## Troubleshooting
The source code for the setup.sh and setup2.sh files were originally from a different repository so changes needed to be made within those scripts to reflect the current working repository before those scripts were able to properly function.  
Circled in red are the changes made in the setup.sh script to reflect the current working repository. The link to the repository was changed as well as the name of the repository directory. 

![Screen Shot 2023-10-13 at 9 09 47 PM](https://github.com/Sameen-k/Deployment5/assets/128739962/170b9f58-0973-4af0-8258-e387ad98173a)

These changes were also made to setup2.sh. Prior to these changes, no HTML changes would reflect on the application.



