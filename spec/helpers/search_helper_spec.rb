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

  it "should display location" do
    location_string(['', '', '']).should be_nil
    location_string(['San-Francisco', '', '']).should have_text('San-Francisco')
    location_string(['San-Francisco', 'CA', '']).should have_text('San-Francisco, CA')
    location_string(['San-Francisco', 'CA', 'US']).should have_text('San-Francisco, CA, US')
  end

end
