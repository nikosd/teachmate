require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchProxyController, "with ulogged in user" do

  it "should redirect to search with only one tag" do
    get "index", :tag => 'hello', :tag_type => 'learn'
    response.should redirect_to('/search?learn=hello')
  end

end

describe SearchProxyController, "with logged in user" do

  before(:all) do
    @user = User.create(:teach_tags_string => 'bass guitar, piano, some other shit', :learn_tags_string => 'hello')
  end

  it "should redirect to search with one selected learn tag and all user's teach tags" do
    session[:user] = @user.id
    get "index", :tag => 'hello', :tag_type => 'learn'
    response.should redirect_to('/search?learn=hello&teach=bass+guitar%2C+piano%2C+some+other+shit')
  end

  it "should redirect to search with one selected learn tag and user's location" do
    session[:user] = @user.id
    @user.update_attributes(:city => "San-Francisco", :region => "CA", :country => "US")
    get "index", :tag => 'hello', :tag_type => 'learn'
    response.should redirect_to('/search?city=san-francisco&country=us&learn=hello&region=ca&teach=bass+guitar%2C+piano%2C+some+other+shit')
  end

  after(:all) do
    @user.destroy
  end

end
