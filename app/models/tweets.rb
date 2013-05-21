require 'core_ext/enumerable'

class Tweets

  class << self

    def weeks(time)
      date = time.to_date
      weeks = []
      begin
        weeks << (date.beginning_of_week..date.end_of_week)
        date += 7
      end while date < Date.today
      weeks
    end

    def collect_with_max_id(collection=[], max_id=nil, &block)
      tweets = retryable(tries: 3, on: Twitter::Error::ServerError, sleep: 0) do
        yield(max_id)
      end
      return collection if tweets.nil?
      collection += tweets.reject(&:retweet?)
      tweets.empty? ? collection.flatten : collect_with_max_id(collection, tweets.last.id - 1, &block)
    end

    def by_week(start=10.weeks.ago)
      opts = {count: 200}
      tweets = collect_with_max_id do |max_id|
        opts[:max_id] = max_id unless max_id.nil?
        client.user_timeline(opts)
      end

      data = {}

      tweets.each do |tweet|
        date = tweet.created_at.to_date
        weeks(start).each do |week|
          data[week.first] ||= 0
          if week.include?(date)
            data[week.first]  += 1
            break
          end
        end
      end

      data
    end

  private

    def client
      @client ||= Twitter::Client.new(
        consumer_key: ENV['TWITTER_CONSUMER_KEY'],
        consumer_secret: ENV['TWITTER_CONSUMER_SECRET'],
        oauth_token: ENV['TWITTER_OAUTH_TOKEN'],
        oauth_token_secret: ENV['TWITTER_OAUTH_TOKEN_SECRET'],
      )
    end

  end

end
