require 'tweetstream'

module TwitterStream

	def self.start
		TweetStream.configure do |config|
			config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
			config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
			config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
			config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
			config.auth_method = :oauth
		end

		all_politicians_twitter_handles = Politician.getAllTwitterHandles

		twitter_handles_sample = all_politicians_twitter_handles.sample(400)

		count = 0

		TweetStream::Client.new.track(twitter_handles_sample) do |status|
			push(status.text, all_politicians_twitter_handles)
			if(count >= 100)
				twitter_handles_sample = all_politicians_twitter_handles.sample(400)
				count = 0;
			end
			count+=1
		end
	end

	def self.push(tweet, twitter_handles)
		filter_tweet(tweet).each do |mention|
			if(twitter_handles.include? mention)
				$redis.RPUSH('twitter_mentions', mention)
			end
		end
	end

	def self.filter_tweet(tweet_text)
		tweet_text.scan(/@\w+/)
	end

end
