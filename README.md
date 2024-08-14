# reorg-casestudy

Steps to proceed:
1. Install Jenkins for CI/CD
2. Create job with the groovy script in jenkins folder and update the required variables
3. Add AWS access and secret keys of user with write permission inside the jenkins server
    "aws configure"
4. Install Terraform
    "apt-get install terraform"
5. Update vars.tfvars as per requirement
6. Build the Jenkins Job
7. Check Build logs for errors.
8. Open Load balancer DNS/Route53 entry in browser.