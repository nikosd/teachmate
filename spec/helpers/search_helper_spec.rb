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

end
