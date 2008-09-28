require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchQuery do

	scenario :search, :root => false

	class SearchQuery
		attr_reader :learn_tags_strings, :teach_tags_strings, :tags
	end

  before(:each) do
		
    users = User.find(:all)
    users.inject(1) do |i, user|
      user.update_attribute(:created_at, i.minutes.ago)
      i+1
    end

    # This query actually means:
    # Find users that have all (not just one of) teach tags and at least one of learn tags.
    @search = 
		SearchQuery.new(:teach => "bass guitar, piano", :learn => "cooking, love people", :per_page => 50)
    @search.store_query
    @search.run
  end

	it "should find taggings" do
		@search.should have(2).learn_tags
		@search.learn_tags[0].learn_taggings.should have(21).learn_taggings
		@search.learn_tags[1].learn_taggings.should have(20).learn_taggings

		@search.should have(2).teach_tags
		@search.teach_tags[0].teach_taggings.should have(20).teach_taggings
		@search.teach_tags[1].teach_taggings.should have(21).teach_taggings
	end

	it "should find users with the given tags" do
		@search.should have(20).users
    @search.users.each {|u| u.last_name.should match(/good_user.*/)}
	end

	it "should find all tags that found users have" do
		@search.should have(7).tags
	end

	it "should not find user, that has only one requested teach tag" do
		@search.users.each {|u| u.last_name.should_not have_text("user_with_one_tag")}
	end

  # This should be changed in future. We should really
  # sort users by the time they update their tags.
  it "should sort users by the time user was created" do
    #puts @search.users.first.created_at
    #puts @search.users.last.created_at
    @search.users.first.created_at.should > @search.users.last.created_at
    
    # With only teach_tags submitted
    new_search = 
    SearchQuery.new(
      :learn => "cooking, love people",
      :per_page => 10
    )
    new_search.run
    new_search.users.first.created_at.should > new_search.users.last.created_at

  end

	it "should page results according to per_page" do
		search = 
		SearchQuery.new(:teach => "bass guitar, piano", :learn => "cooking, love people", :per_page => 11)
		search.per_page.should == 11
	end

	it "should use default per_page if I try to set it to something weird" do
		search = 
		SearchQuery.new(:teach => "bass guitar, piano", :learn => "cooking, love people", :per_page => 'aaggghhh')
		search.per_page.should == 10
	end

  it "should save my query if it's not already in DB, otherwise just get the existing query ID" do
    query = SearchQuery.find(
      :first, 
      :conditions => "teach_string = 'bass guitar, piano' and learn_string = 'cooking, love people'"
    )

    new_query = SearchQuery.new(:teach => "bass guitar, piano", :learn => "cooking, love people")
    new_query.store_query
    new_query.id.should == query.id
  end

end

describe SearchQuery, "with bad params" do

  scenario :search, :root => false

  it "should add errors if there's too much learn tags" do
    search = 
    SearchQuery.new(
      :teach => "bass guitar, piano",
      :learn => "cooking, love people, blablah, blah",
      :per_page => 50
    )
    search.run
    search.errors.on(:learn).should_not be_nil
  end

  it "should add errors if there's too much learn tags" do
    one_hundred = []
    1.upto(101) {|n| one_hundred << n}
    one_hundred = one_hundred.join(', ')
    
    search = 
    SearchQuery.new(
      :teach => one_hundred,
      :learn => "cooking, love people",
      :per_page => 50
    )
    search.run
    search.errors.on(:teach).should_not be_nil
  end

  it "should add error to base if search query is empty" do
    search = SearchQuery.new(:teach => '')
    search.run
    search.errors.on(:base).should_not be_nil
  end

  it "should find nothing if the first teach_tag doesn't match any users" do
    search = SearchQuery.new(:learn => 'bad tag, cooking', :per_page => 50)
    search.run
    search.users.should have(0).users
  end


end

describe SearchQuery, "special cases" do

  scenario :search, :root => false

  it "should search find users only by their teach_tags" do
    search = 
    SearchQuery.new(
      :learn => "teach",
      :per_page => 50
    )
    search.run
    search.should have(10).users
  end

  it "should search find users only by their learn_tags" do
    search = 
    SearchQuery.new(
      :teach => "learn",
      :per_page => 50
    )
    search.run
    search.should have(10).users
  end


  it "should not find more than one pages of users" do
    search = 
    SearchQuery.new(
      :learn => "cooking, love people",
      :per_page => 10
    )
    search.run
    search.users.total_pages.should == 2
  end

  it "should not find user when no user has one of submitted teach_tags" do
    search = 
    SearchQuery.new(
      :learn => "cooking, love people, jepp yebrillo",
      :teach => "bass guitar, piano",
      :per_page => 50
    )
    search.run
  end

end

describe SearchQuery, "with location" do

  scenario :search, :root => false

  it "should find users from submitted location" do
    search = 
		SearchQuery.new(
      :learn => "cooking, love people", 
      :teach => "bass guitar, piano",
      :city  => "San-Francisco",
      :country  => "US",
      :per_page => 50
    )
    search.run
    search.users.should have(10).users
  end

  it "should find users from submitted locations (only learn_tags used)" do
    search = 
		SearchQuery.new(
      :teach => "bass guitar, piano",
      :city  => "San-Francisco",
      :country  => "US",
      :per_page => 50
    )
    search.run
    search.users.should have(10).users
  end

end
