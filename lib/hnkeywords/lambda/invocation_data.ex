defmodule Hnkeywords.Lambda.InvocationData do
  def get_lambda_runtime_aws_request_id(invocation_data) do
    with x when not is_nil(x) <-
           :proplists.get_value("Lambda-Runtime-Aws-Request-Id", invocation_data, nil) do
      x
      |> to_string()
    end
  end

  def get_lambda_runtime_deadline_ms(invocation_data) do
    with x when not is_nil(x) <-
           :proplists.get_value("Lambda-Runtime-Deadline-Ms", invocation_data, nil) do
      x
      |> to_string()
      |> String.to_integer()
    end
  end

  def get_lambda_runtime_invoked_function_arn(invocation_data) do
    with x when not is_nil(x) <-
           :proplists.get_value("Lambda-Runtime-Invoked-Function-Arn", invocation_data, nil) do
      x
      |> to_string()
    end
  end

  def get_lambda_runtime_trace_id(invocation_data) do
    with x when not is_nil(x) <-
           :proplists.get_value("Lambda-Runtime-Trace-Id", invocation_data, nil) do
      x
      |> to_string()
    end
  end

  def get_lambda_runtime_client_context(invocation_data) do
    with x when not is_nil(x) <-
           :proplists.get_value("Lambda-Runtime-Client-Context", invocation_data, nil) do
      x
      |> to_string()
    end
  end

  def get_lambda_runtime_cognito_identity(invocation_data) do
    with x when not is_nil(x) <-
           :proplists.get_value("Lambda-Runtime-Cognito-Identity", invocation_data, nil) do
      x
      |> to_string()
    end
  end
end