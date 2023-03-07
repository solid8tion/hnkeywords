import Config

config :hnkeywords, ecto_repos: [Hnkeywords.Repo]

config :hnkeywords, 
	default_story_limit: 10,
	default_keyword_limit: 10,
	default_days_from: 30,
	openai_model: "gpt-3.5-turbo-0301",
	timer_func: :runall,
	timer_interval_ms: 43200000_000 # 12 hours