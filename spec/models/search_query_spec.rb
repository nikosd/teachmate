require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchQuery do

	scenario :search, :root => false

	class SearchQuery
		attr_reader :learn_tags_strings, :teach_tags_strings, :tags
	end

  before(:each) do
		@search = 
		SearchQuery.new(:teach => "bass guitar, piano", :learn => "cooking, love people", :per_page => 50)
    @search.store_query
    @search.run
  end

	it "should find taggings" do
		@search.should have(2).learn_tags
		@search.learn_tags[0].learn_taggings.length.should == 21
		@search.learn_tags[1].learn_taggings.length.should == 20

		@search.should have(2).teach_tags
		@search.teach_tags.each do |t|
			t.should have(20).teach_taggings
		end
	end

	it "should find users with the given tags" do
		@search.should have(20).users
		@search.users.each {|u| u.second_name.should match(/good_user.*/)}
	end

	it "should find all tags that found users have" do
		@search.should have(5).tags
	end

	it "should not find user, that has only one requested teach tag" do
		@search.users.each {|u| u.second_name.should_not have_text("user_with_one_tag")}
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
