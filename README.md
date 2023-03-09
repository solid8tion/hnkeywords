# Hnkeywords

This application retrieves the latest Hacker News stories, extracts keywords, and perists the information in an DB.  It will retrieve the top trending keywords for the last X days.

This application is designed to run on AWS Lambda using a Docker image.  In a local environment it can run via timed triggers.

## Installation

### Set ENV Vars

Add the following environment variables in a new file `.env`
```
OPENAI_SECRET=<OPENAI_API_SECRET_KEY>
S3_BUCKET=<AWS_S3_BUCKET> # to store SQLite DB file
SENDER_EMAIL=<YOUR_EMAIL> # verified email on AWS SES to send emails from
DB_FILENAME=<SQLITE_DB_FILENAME>
AWS_REGION=<YOUR_AWS_REGION>
AWS_ACCESS_KEY_ID=<<YOUR_ACCESS_KEY_ID>
AWS_SECRET_ACCESS_KEY=<YOUR_SECRET_ACCESS_KEY>
```

You can set the following arguments, all optional, when triggering the Lambda function:
```
{
  "days_from": 30, // the last number of days from which to retrieve the trending keyword data, defaults to 30
  "story_limit": 25, // the number of stories to use from Hacker News, defaults to 25
  "keyword_limit": 10, // the number of trending keywords to retrieve, defaults to 10
  "send_email": true, // set it to false to disable the email, defaults to true
  "to": "youremail@domain.com" // the destination email, defaults to the sender email address
}
```

#### Run as Lambda function

1. Login to the public AWS ECR repository

    `aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws`

2. Build your image locally using the docker build command.

    `docker build -t hnkeywords:latest .`

3. Run your container image locally using the docker run command.

    `docker run --env-file .env -p 9000:8080 hnkeywords:latest`

    This command runs the image as a container and starts up an endpoint locally at `localhost:9000/2015-03-31/functions/function/invocations`.

4. Trigger the Lambda function to the following endpoint using a curl command:

    ```
    curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"days_from": 30,"story_limit": 5,"keyword_limit": 5,"send_email":false}'
    ```

    This command invokes the function running in the container image and returns a response.


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
* https://docs.aws.amazon.com/lambda/latest/dg/runtimes-api.html
* https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/
* https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/RunLambdaSchedule.html
* https://shpals.medium.com/create-aws-lambda-from-ecr-docker-image-and-integrate-it-with-github-ci-cd-pipeline-dfa3015b5ee0
* https://dev.to/aws-builders/deploying-a-container-image-to-aws-ecr-using-a-github-action-k33

