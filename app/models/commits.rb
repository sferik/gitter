require 'core_ext/enumerable'

class Commits

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

    def by_week(start=10.weeks.ago)
      commits = client.repos(ENV['GITHUB_LOGIN'], sort: "pushed", per_page: 100).threaded_map do |repo|
        retryable(tries: 3, on: Octokit::Error, sleep: 0) do
          client.commits(repo.full_name, "master", per_page: 100)
        end
      end.flatten

      # Select my commits
      commits.select! do |commit|
        commit.author && commit.author.login == ENV['GITHUB_LOGIN']
      end

      data = {}

      commits.each do |commit|
        date = Date.parse(commit.commit.author.date)
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
      @client ||= Octokit::Client.new(
        login: ENV['GITHUB_LOGIN'],
        oauth_token: ENV['GITHUB_OAUTH_TOKEN'],
      )
    end

  end

end
