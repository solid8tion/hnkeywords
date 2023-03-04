defmodule Hnkeywords.Repo do
  use Ecto.Repo,
    otp_app: :hnkeywords,
    adapter: Ecto.Adapters.SQLite3
end
