defmodule Hnkeywords.Services.Aws do
  require ExAws.S3

  def upload_db do
  	s3_bucket = Application.get_env(:hnkeywords, :s3_bucket)
  	db_filename = Application.get_env(:hnkeywords, :db_filename)
  	db_filepath = Application.get_env(:hnkeywords, :db_filepath)
    case File.read(db_filepath) do
	  {:ok, body} -> 
	  	headers = %{"Content-Type" => "application/octet-stream"}

		ExAws.S3.put_object(s3_bucket, db_filename, body, headers)
		|> ExAws.request!()
		{:ok, "File uploaded successfully."}

	  {:error, reason} -> 
	  	{:error, "Error reading file: #{reason}"}
	end
  end
end
