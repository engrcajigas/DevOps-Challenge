| ![Diagram](/diagrams/diagram.jpeg) |
| :--: |
| <b> Architecture diagram for the given challenge </b> |

### Pre-requisites:

* Terraform installed locally. (Instructions [here](https://learn.hashicorp.com/tutorials/terraform/install-cli))
* An AWS CLI profile as desribe [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html).
This project uses the profile named "`stephane`". To use a different AWS profile, change the entry in the <b>`variables.tf`</b> file in the root directory.

After cloning the repository, do the following:
1. Rename <b>`template.terraform.tfvars`</b> to <b>`terraform.tfvars`</b>
2. Change values of the variables <b>`AWS_ACCESS_KEY`</b> and <b>`AWS_SECRET_KEY`</b>
3. Run <b>`terraform init`</b>
4. Run <b>`terraform plan`</b>
5. Run <b>`terraform apply`</b>


Open the provided <b>`alb_url`</b> in your browser to access your webserver. (It can be found as an output on the console where `terraform apply` is run)

### (Optional) Testing AWS Auto Scaling Policies using Stress:

The auto scaling group is configured to scale up when it breached an 80% threshold, and scale down once usage is dropped below 60%.
There is one way to test if it is working as desired, it is by using <b>stress</b> tool. 

Install stress on your instance:
1. Connect to your instance using <b>Session Manager</b>
2. Install stress using the command <b>`sudo yum install stress -y`</b>.

Once installed, use stress by running:
<b>`sudo stress --cpu 1 --timeout 600`</b>
The above command will generate a thread to max out a single CPU core for 600 seconds.
After a while, the scaling up alarm will be triggered and a new instance will be provision.

Once Stress process is finished, and CPU utilization is back to normal level auto scaling will terminate an instance in the group as defined by our scaling down policy.
