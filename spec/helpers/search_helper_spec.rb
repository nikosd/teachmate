require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchHelper do

	include SearchHelper
	scenario :search, :root => false
  
	before(:each) do
		@search = 
		SearchQuery.new(:teach => "bass guitar, piano", :learn => "cooking, love people")
    @search.run
	end

	it "should display tags of each found user" do
		tags1 = show_tags(@search.users[0], :learn)
    tags1.should include_text('<strong>piano</strong>')
    tags1.should include_text('<strong>bass guitar</strong>')
    tags1.should include_text('unrelated tag')
	end

  it "should display no more than 10 tags for each user" do
  
    user = User.create(:teach_tags_string => "cooking, love people, tag1, tag2, tag3, tag4, tag5, tag6, tag7, tag8, tag9, tag10", :city => 'Los-Angeles')
    @search = SearchQuery.new(:learn => 'cooking', :city => 'Los-Angeles')
    @search.run
    
    show_tags(@search.users[0], :teach).split(', ').length.should == 10

  end

end
