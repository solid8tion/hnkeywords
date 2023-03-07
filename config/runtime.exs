import Config

db_filename = case config_env() do
  :prod -> "prod.db"
  _ -> "dev.db"
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

if System.get_env("AWS_SESSION_TOKEN") do
  config :ex_aws,
    json_codec: Jason,
    region: [{:system, "AWS_REGION"}, :instance_role] ,
    access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role], 
    secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
    security_token: [{:system, "AWS_SESSION_TOKEN"}, :instance_role]
else
  config :ex_aws,
    json_codec: Jason,
    region: {:system, "AWS_REGION"},
    access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
    secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"}
end

config :hnkeywords, Hnkeywords.Mailer,
  adapter: Bamboo.SesAdapter