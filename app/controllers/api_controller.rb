class ApiController < ApplicationController

  def statusboard
    commits = Thread.new{Commits.by_week}
    tweets = Thread.new{Tweets.by_week}
    datasequences = [
      {
        title: "GitHub Commits",
        color: "green",
        datapoints: format_datapoints(commits.value)
      },
      {
        title: "Tweets",
        color: "aqua",
        datapoints: format_datapoints(tweets.value)
      },
    ]
    @data = {
      graph: {
        datasequences: datasequences,
        refreshEveryNSeconds: 86400,
        title: "Erik's Weekly Activity",
        total: true,
      }
    }
    render json: @data
  end

  private

  def format_datapoints(activities)
    activities.map{|week, count| {title: week, value: count}}.sort_by{|h| h[:title]}
  end

end
