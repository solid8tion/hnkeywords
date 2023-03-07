# Hnkeywords

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `hnkeywords` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hnkeywords, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/hnkeywords>.

## Publish for AWS Lambda

### Build Docker and Add to ECR Repo
```
$ docker build -t hello_lambda .
$ aws ecr create-repository --repository-name hnkeywords-repo --region us-east-1
$ aws ecr get-login-password | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID".dkr.ecr.us-east-1.amazonaws.com/hnkeywords-repo"
$ docker tag hnkeywords "$AWS_ACCOUNT_ID".dkr.ecr.us-east-1.amazonaws.com/hnkeywords-repo
$ docker push "$AWS_ACCOUNT_ID".dkr.ecr.us-east-1.amazonaws.com/hnkeywords-repo
```

https://github.com/niku/lambda_elixir_on_docker_example

https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/

https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/RunLambdaSchedule.html

