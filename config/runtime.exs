import Config

db_filename = cond do
  System.get_env("DB_FILENAME") -> System.get_env("DB_FILENAME")
  config_env() == :prod -> "prod.db"
  true -> "dev.db"
end

db_filepath = "/tmp/#{db_filename}"

poller_type = case config_env() do
  :prod -> :lambda
  _ -> :timer
end

config :hnkeywords, 
  openai_secret: System.fetch_env!("OPENAI_SECRET"),
  s3_bucket: System.fetch_env!("S3_BUCKET"),
  db_filename: db_filename,
  db_filepath: db_filepath,
  sender_email: System.fetch_env!("SENDER_EMAIL"),
  send_email: true,
  poller: poller_type

config :hnkeywords, Hnkeywords.Repo,
  database: db_filepath,
  synchronous: :full,
  journal_mode: :off,
  log: :false

config :ex_aws,
  json_codec: Jason,
  region: {:system, "AWS_REGION"},
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"}

if System.get_env("AWS_SESSION_TOKEN") do
  config :ex_aws,
    security_token: {:system, "AWS_SESSION_TOKEN"}
end