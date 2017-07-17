# TasksApi
Serverless Task App

# Summary
I'll use this section to provide some insight into my approach to this assignment and thought process behind some of my decisions.

Although I have played around with EC2 instances in the past and PaaS systems that run on AWS such as Heroku, this assignment did drive me to learn more about AWS than I have in the past. As such, my approach to this assignment began with a lot of reading:

  1. [AWS Lambda: A Guide to Serverless Microservices](https://www.amazon.com/AWS-Lambda-Guide-Serverless-Microservices-ebook/dp/B016JOMAEE) - by Matthew Fuller
  2. AWS Lambda documentation
  3. AWS DynamoDB documentation
  4. AWS API Gateway documentation

  etc

After getting a feel for Lambdas and the AWS ecosystem, I researched a few of the frameworks mentioned in the *AWS Lambda* book such as Serverless and Chalice. I looked at sample Lambda function code written in different languages along with the samples from Serverless. Although Java appears to have the best *hot* runtime performance, it also has the worst *cold* performance, and it also looked too verbose for my taste. I saw that the GOLANG shims were written in Python since they appear to have the best *cold* load performance. Since I'm a fan of Python and I liked that I could use the Lambda console to edit code in place and test without redeploying, I decided to use Python for the assignment.

Next step was to build out some functioning Lambda functions and see it working with the database. I created everything through the console without concerning myself too much about style, validations, output format, etc. I was able to get all the CRUD operations working as well as the daily email lambda. As I was going through this exercise, I manually configured the roles and policies following the principle of least privilege. Each function only had permissions to do their specific task.

Then I started to play with the API Gateway. I manually crafted a Swagger file for the API using the JSON Schema that was included in the assignment. I was able to import it through the console and then start reverse engineering some of the API Gateway configuration. I was able to hook all the methods up to the corresponding Lambda functions and test via Postman.

Now that I had the rough skeleton of everything working together, I moved on to looking at Terraform. Once I had Terraform somewhat figured out, I felt that I could start checking in code to a Git repo, deploy/test and iterate on these "vertical slices".

Tangential note on Git aspects of this assignment: I originally looked at BitBucket since it offers free private repos, but I didn't realize they don't have support for GPG signed commits yet. So I went with GitHub. </end-tangent>

I did some Googling to see if there was a way to generate a Terraform config based on already existing AWS resources. I came across a little project on GitHub called *[terraforming](https://github.com/dtan4/terraforming)*. I used it to help me get started with my Terraform config, but I had to do quite a bit of cleanup and it wasn't able to help with the API Gateway.

The current state of the repo includes the Terraform config for deploying the Create and Read functions, the daily email function, the CloudWatch daily event rule, the API Gateway with GET and POST methods on the "/tasks" resource, all reading from a DynamoDB table called "Tasks". (And all necessary IAM roles/policies)

# TODO
  * Finalize unit testing pattern for Lambda functions.
    * Research moto library vs other mocking/patching frameworks for boto3
  * Add some kind of BDD style testing for terraform config.
    * Research Cucumber, RSpec
  * Complete other "slices" of functionality (i.e. update and delete)
  * Research DynamoDB Global Secondary Indices to accomplish desired sort for GET endpoint (billing model of Lambda incentivizes offloading work from Lambda to other parts of the pipeline)
  * Research Amazon Cognito for permissions around sharing tasks with other users
  * Clean up emailer Lambda to properly scan and group incomplete tasks by user. And properly format outgoing email.
  * Export Swagger doc + Gateway extensions
