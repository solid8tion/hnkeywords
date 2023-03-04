import Config

openai_secret =
    System.get_env("OPENAI_SECRET") ||
      raise """
      environment variable OPENAI_SECRET is missing.
      """

bucket_name = case config_env() do
  :prod -> "hnkeywords-prod"
  _ -> "hnkeywords-dev"
end

db_filename = "hnkeywords.db"
db_filepath = "/tmp/#{db_filename}"
sender_email = System.get_env("SENDER_EMAIL")

config :hnkeywords, 
  openai_secret: openai_secret,
  s3_bucket: bucket_name,
  db_filename: db_filename,
  db_filepath: db_filepath,
  sender_email: sender_email

config :hnkeywords, Hnkeywords.Repo,
  database: db_filepath,
  synchronous: :full,
  journal_mode: :off

config :ex_aws,
  json_codec: Jason,
  region: "us-east-1",
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"}

config :hnkeywords, Hnkeywords.Mailer,
  adapter: Bamboo.SesAdapter