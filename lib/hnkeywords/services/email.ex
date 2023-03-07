defmodule Hnkeywords.Services.Email do
  import Bamboo.Email
  alias Hnkeywords.Mailer

  def send(datetime, stories, keywords, days_from, to) do
  	html_body = format_stories(datetime, stories) <> "<br><hr><br>" <> format_keywords(keywords, days_from)
  	new_email(
      to: to,
      from: Application.get_env(:hnkeywords, :sender_email),
      subject: "HN Keywords #{datetime}",
      html_body: html_body
    )
    |> Mailer.deliver_later()
  end

  defp format_stories(datetime, stories) do
  	"<h2>Top Stories for #{datetime}</h2><ol>" <>
  	Enum.map_join(stories, fn {keywords, {hn_id, title, url, _index}} -> "<li><a href='https://news.ycombinator.com/item?id=#{hn_id}'>#{title}</a><br><a href='#{url}'>#{url}</a><br>[#{Enum.join(keywords, ", ")}]</li>" end) <>
  	"</ol>"
  end

  defp format_keywords(keywords, days_from) do
  	"<h2>Top Keywords for the last #{days_from} days</h2><ul>" <>
  	Enum.map_join(keywords, fn [count | rank_keyword] -> "<li>#{count} - #{tl(rank_keyword)}</li>" end) <>
  	"</ul>"
  end

end