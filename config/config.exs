import Config

config :hnkeywords, ecto_repos: [Hnkeywords.Repo]

config :hnkeywords, Hnkeywords.Mailer,
  adapter: Bamboo.SesAdapter

config :hnkeywords, 
	default_story_limit: 25,
	default_keyword_limit: 10,
	default_days_from: 30,
	send_email: true,
	openai_model: "gpt-4o-mini",
	timer_func: :runall,
	timer_interval_ms: 43200000_000 # 12 hours