require "spec_helper"

describe Commits do

  describe "#weeks" do

    before do
      Timecop.freeze(Time.utc(2013, 5, 9, 16, 20, 0))
    end

    after do
      Timecop.return
    end

    it "returns an array of weeklong ranges from the week of an initial date through the current week" do
      weeks = Commits.weeks(10.weeks.ago.to_date)
      expect(weeks).to be_an Array
      expect(weeks.first).to be_a Range
      expect(weeks.first.first).to eq Date.parse("Mon, 25 Feb 2013")
    end

  end

  describe "#by_week" do

    before do
      Timecop.freeze(Time.utc(2013, 5, 9, 16, 20, 0))
      stub_request(:get, "https://api.github.com/users/sferik/repos").
        with(query: {sort: "pushed", per_page: "100"}).
        to_return(body: fixture("repos.json"), headers: {content_type: "application/json"})
      stub_request(:get, "https://api.github.com/repos/pengwynn/octokit/commits").
        with(query: {sha: "master", per_page: "100"}).
        to_return(body: fixture("commits.json"), headers: {content_type: "application/json"})
    end

    after do
      Timecop.return
    end

    it "returns a data hash" do
      by_week = Commits.by_week
      expect(by_week).to be_a Hash
      expect(by_week.keys).to be_an Array
      expect(by_week.keys.first).to eq Date.parse("Mon, 25 Feb 2013")
      expect(by_week.values).to be_an Array
      expect(by_week.values.first).to eq 2
    end

  end

  describe "#client" do

    it "returns an authenticated client" do
      client = Commits.send(:client)
      expect(client).to be_an Octokit::Client
      expect(client).to be_oauthed
    end

  end

end
