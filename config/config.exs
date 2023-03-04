import Config

config :hnkeywords, ecto_repos: [Hnkeywords.Repo]

config :hnkeywords, 
	fetch_item_limit: 10,
	fetch_keyword_limit: 10,
	fetch_from: 7 #days
