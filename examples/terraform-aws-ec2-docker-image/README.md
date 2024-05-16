__Newsletter Automation app deployment using Terraform__
------

This folder contains Terraform Configuration files to deploy app. These configuration provisions 
    
    a) An EC2: Deploys an ec2 instance with required software installations to run the app.
    
    b) a Lambda
    
    c) SQS

    d) Automatically generates secure Key pair and stores the private key in `/tmp' directory.

__1. Pre-requisites__

A) [AWS credentials configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

    AWS uses credentials to authorize and authenticate. The credential file is located at ~/.aws/credentials on Linux or mac OS, c:\users\USERNAME\.aws\credentials on Windows. As part of the configuration set these three values as Environment Variables AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY , and AWS_SESSION_TOKEN(not compulsory). Follow the provided link for details.

__2. Terraform-Installation__
------

A) [Terraform](https://phoenixnap.com/kb/how-to-install-terraform)

    Terraform is a DevOps tool created by HashiCorp written in Go lang. Terraform used to deploy Infrastructure on any cloud like AWS, Azure, Google etc... and used to automate the Infrastructure tasks.

B) Run the commands from the terminal:

	1. `curl -fsSL https://apt.releases.hashicorp.com/gpg` | `sudo apt-key add -`
	
    2. `sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"`
	
    3. `sudo apt-get update && sudo apt-get install terraform`

C) Test the installation of Terraform is successfull by running the command  `terraform version`

__3. Steps to follow deploy the app__
------

a) [Clone the newsletter_automation repo](https://github.com/qxf2/newsletter_automation.git)

b) change directory(cd) to `cd terraform`.

c) Change the default values in "variable.tf" 

    c1) aws region - by default 'us-east-1'. Modify as per your requirement.
    
    c2) aws profile - Modify as per your requirement.

d) The mentioned Environment variables are used in Lambda creation - `CHATGPT_API_KEY`, `API_KEY_VALUE`, `ChannelID`, `Qxf2Bot_USER`, `ETC_CHANNEL` and these values are secrete values so to be provided in `terraform.tfvars` file under `terraform` directory.

e) Keep these default values as is in `variable.tf` for `private_key_path`, `github_repo`, `github_repo_name`, `lambda_function_name`, `lambda_handler`, 
`lambda_runtime`, `lambda_filename`.

f) Run from the command line(cd terraform)  `terraform fmt --check` command to format configuration files and to validate `terraform validate`(static analysis check- pops up errors if any).

g) Run `terraform init` - 
    Initializes the working directory(terraform dir) and downloads the necessary provider plugins, modules and setting up the backend for storing your infrastructure's state.

h) Run `terraform plan` 
    Generate and shows an execution plan (without applying it)

i) Run `terraform apply` 
    Apply the Infrastructure changes.

j) Run `terraform destroy` --auto-approve(to avoid prompt) to     destroy's the newsletter automation app instance including private key stored in `tmp' directory.