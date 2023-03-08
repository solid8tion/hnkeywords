# Hnkeywords

This application retrieves the latest Hacker News stories, extracts keywords, and perists the information in an DB.  It will retrieve the top trending keywords for the last X days.

This application is designed to run on AWS Lambda using a Docker image.  In a local environment it can run via timed triggers.

## Installation

### ENV Vars

Set the following environment variables:
```
export OPENAI_SECRET=<OPENAI_API_SECRET_KEY>
export S3_BUCKET=<AWS_S3_BUCKET> # to store SQLite DB file
export SENDER_EMAIL=<YOUR_EMAIL> # verified email on AWS SES to send emails from
```

Also set the following AWS credentials if testing on local:
```
export AWS_REGION=<YOUR_AWS_REGION>
export AWS_ACCESS_KEY_ID=<<YOUR_ACCESS_KEY_ID>
export AWS_SECRET_ACCESS_KEY=<YOUR_SECRET_ACCESS_KEY>
```

You can set the following arguments when triggering the Lambda function:
```
{
  "days_from": 30, // the last number of days from which to retrieve the trending keyword data
  "story_limit": 25, // the number of stories to use from Hacker News
  "keyword_limit": 25, // the number of trending keywords to retrieve
  "send_email": true, // set it to false to disable the email
  "to": "youremail@domain.com" // the destination email
}
```

## Deploy to AWS ECR/Lambda

### Github Actions

You can use the Github actions workflow included to deploy the app.  Set `AWS_REGION`, `YOUR_ACCESS_KEY_ID`, `YOUR_SECRET_ACCESS_KEY` as repository secrets in Github.  You will first need to give the AWS user the necessary permissions to access ECR and deploy to Lambda.  You will also need to create a repository in AWS ECR:

```
$ aws ecr create-repository --repository-name hnkeywords --region us-east-1
```

### Manual Publish to ECR

You can also manually publish to AWS ECR using the below steps:

```
$ docker build -t hnkeywords .
$ aws ecr get-login-password | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID".dkr.ecr.us-east-1.amazonaws.com/hnkeywords"
$ docker tag hnkeywords "$AWS_ACCOUNT_ID".dkr.ecr.us-east-1.amazonaws.com/hnkeywords
$ docker push "$AWS_ACCOUNT_ID".dkr.ecr.us-east-1.amazonaws.com/hnkeywords
```

## References

* https://github.com/niku/lambda_elixir_on_docker_example
* https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/
* https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/RunLambdaSchedule.html
* https://shpals.medium.com/create-aws-lambda-from-ecr-docker-image-and-integrate-it-with-github-ci-cd-pipeline-dfa3015b5ee0
* https://dev.to/aws-builders/deploying-a-container-image-to-aws-ecr-using-a-github-action-k33

