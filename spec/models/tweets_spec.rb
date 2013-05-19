require "spec_helper"

describe Tweets do

  describe "#weeks" do

    before do
      Timecop.freeze(Time.utc(2013, 5, 9, 16, 20, 0))
    end

    after do
      Timecop.return
    end

    it "returns an array of weeklong ranges from the week of an initial date through the current week" do
      weeks = Tweets.weeks(10.weeks.ago.to_date)
      expect(weeks).to be_an Array
      expect(weeks.first).to be_a Range
      expect(weeks.first.first).to eq Date.parse("Mon, 25 Feb 2013")
    end

  end

  describe "#by_week" do

    before do
      Timecop.freeze(Time.utc(2013, 5, 9, 16, 20, 0))
      stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json").
        with(query: {count: "200"}).
        to_return(body: fixture("user_timeline.json"), headers: {content_type: "application/json"})
      stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json").
        with(query: {count: "200", max_id: "305090341130878975"}).
        to_return(body: fixture("empty_array.json"), headers: {content_type: "application/json"})
    end

    after do
      Timecop.return
    end

    it "returns a data hash" do
      by_week = Tweets.by_week
      expect(by_week).to be_a Hash
      expect(by_week.keys).to be_an Array
      expect(by_week.keys.first).to eq Date.parse("Mon, 25 Feb 2013")
      expect(by_week.values).to be_an Array
      expect(by_week.values.first).to eq 94
    end

  end

  describe "#client" do

    it "returns an authenticated client" do
      client = Tweets.send(:client)
      expect(client).to be_an Twitter::Client
      expect(client).to be_credentials
    end

  end

end
