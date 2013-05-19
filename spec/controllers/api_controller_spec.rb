require 'spec_helper'

describe ApiController do

  describe "#statusboard" do

    before do
      Timecop.freeze(Time.utc(2013, 5, 9, 16, 20, 0))
      stub_request(:get, "https://api.github.com/users/sferik/repos").
        with(query: {sort: "pushed", per_page: "100"}).
        to_return(body: fixture("repos.json"), headers: {content_type: "application/json"})
      stub_request(:get, "https://api.github.com/repos/pengwynn/octokit/commits").
        with(query: {sha: "master", per_page: "100"}).
        to_return(body: fixture("commits.json"), headers: {content_type: "application/json"})
      stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json").
        with(query: {count: "200"}).
        to_return(body: fixture("user_timeline.json"), headers: {content_type: "application/json"})
      stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json").
        with(query: {count: "200", max_id: "305090341130878975"}).
        to_return(body: fixture("empty_array.json"), headers: {content_type: "application/json"})
      get :statusboard
      @data = assigns(:data)
      @response = response
    end

    after do
      Timecop.return
    end

    it "responds successfully" do
      expect(@response).to be_success
    end

    it "assigns a data hash" do
      expect(@data).to be_a Hash
    end

    it "data hash contains a graph key" do
      expect(@data[:graph]).to be_a Hash
    end

    it "graph has a title" do
      expect(@data[:graph][:title]).to eq "Erik's Weekly Activity"
    end

    it "graph contains data sequences" do
      expect(@data[:graph][:datasequences]).to be_an Array
    end

  end

end
