require File.expand_path(File.dirname(__FILE__) + "/helper")

Story "subscribe to a search query", %{
  As a User
  I want to subscribe to searh query
  So that I can see my subscriptions and manage them later 
}, :type => RailsStory do

  Scenario "registered user" do
    
    Given(
      "my search query with learn '$learn_string' and teach '$teach_string'",
      'love people', 'bass guitar') do |learn_string, teach_string|
      @learn = learn_string
      @teach = teach_string
    end
    And("my user id") do
      @user = User.create!()
    end

    When("I enter click subscribe button on search results page") do
      request.session[:user] = @user.id
      post(
        'subscriptions', 
        :search_query => {:learn_string => @learn, :teach_string => @teach}
      )
    end

    Then("A new subscription should be added") do
      Subscription.find_by_user_id(@user.id).should_not be_nil
    end
    And("I should be redirected to my search results")

  end

end
