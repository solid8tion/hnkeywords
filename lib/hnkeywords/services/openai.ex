'''
curl https://api.openai.com/v1/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{
  "model": "text-davinci-003",
  "prompt": "Extract keywords from these titles\n\n0: Our Reality May Be a Sum of All Possible Realities\n1: Email: Explained from First Principles\n2: C-rusted: The Advantages of Rust, in C, without the Disadvantages\n3: Two Jewish Kids in 1930s Cleveland Altered American Pop Culture\n4: Self hosting in 2023\n5: Using AI tools to design an entire website\n6: Lesser known tricks, quirks and features of C\n7: Open source solution replicates ChatGPT training process\n8: Local-First Web Development\n9: Writing an Engineering Strategy\n\n",
  "temperature": 1,
  "max_tokens": 185,
  "top_p": 1,
  "frequency_penalty": 0.8,
  "presence_penalty": 0
}'

{"id":"cmpl-6lsO1wOexamcj2Fcpr8Q8dUUAd9Kq","object":"text_completion","created":1676868497,"model":"text-davinci-003",
"choices":[{"text":"\n1. Reality, Sum, Realities \n2. Email, First Principles\n3. Rust, C, Advantages, Disadvantages\n4. Jewish Kids, 1930s Cleveland, American Pop Culture \n5. AI tools, Design Website \n6. Tricks Quirks Features of C \n7. Open Source Solution, ChatGPT Training Process \n8. Local-First Web Development  \n9. Engineering Strategy",
"index":0,"logprobs":null,"finish_reason":"stop"}],"usage":{"prompt_tokens":130,"completion_tokens":93,"total_tokens":223}}
'''
defmodule Hnkeywords.Services.Openai do
  
  @completions_url "https://api.openai.com/v1/chat/completions"
  @recv_timeout 20_000

  def compute(titles) do
    format_prompt(titles)
  	|> fetch_completion
  	|> IO.inspect
    |> format_results(titles)
  end

  defp format_results({:ok, %{ "choices" => [%{ "message" => %{ "content" => resp} } | _]}}, titles) do
    String.split(resp, "\n", trim: true)
    |> Enum.map(fn text -> String.split(text, ": ") 
      |> List.last 
      |> String.replace(~r/^\s+|(\.|;)*\s*\z/, "")
      |> String.downcase
      |> String.split(", ", trim: true)
    end)
    |> Enum.zip(titles)
  end

  defp format_prompt(titles) do
  	"Extract the main keywords that can be taggable from each of these titles and don't repeat the title in the answer: " <>
  	Enum.map_join(titles, fn {_hn_id, title, _url, index} -> "#{index}: #{title}, " end)
  end

  defp fetch_completion(prompt) do
  	headers = [{"Content-Type", "application/json"}, {"Authorization", "Bearer #{Application.get_env(:hnkeywords, :openai_secret)}"}]
  	#payload = %{:model => "text-davinci-003", :temperature => 0, :max_tokens => 500, :top_p => 1, :frequency_penalty => 0.8, :presence_penalty => 0, :prompt => prompt}
  	payload = %{:model => Application.get_env(:hnkeywords, :openai_model), :messages => [%{:role => "system", :content => "You are a helpful assistant that extracts keywords from texts."}, %{:role => "user", :content => prompt}]}
    body = Jason.encode!(payload)
  	case HTTPoison.post(@completions_url, body, headers, [recv_timeout: @recv_timeout]) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        {:ok, Jason.decode!(body) }
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found }
      {:ok, %HTTPoison.Error{reason: reason}} ->
        {:error, reason }
    end
  end

end

