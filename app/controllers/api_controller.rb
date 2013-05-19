class ApiController < ApplicationController

  def statusboard
    commits = Thread.new{Commits.by_week}
    tweets = Thread.new{Tweets.by_week}
    datasequences = [
      {
        title: "GitHub Commits",
        color: "green",
        datapoints: commits.value.map{|week, count| {title: week, value: count}}.sort_by{|h| h[:title]},
      },
      {
        title: "Tweets",
        color: "aqua",
        datapoints: tweets.value.map{|week, count| {title: week, value: count}}.sort_by{|h| h[:title]},
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

end
