require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchController do

	scenario :search, :root => false

	before(:each) do
		get 'index', :teach => "bass guitar, piano", :learn => "cooking, love people", :per_page => "50"
	end

	it "should find all requested users" do
		 assigns[:users].length.should == 20
		 assigns[:users].each {|u| u.second_name.should match(/good_user/)}
	end

	it "should render index.html" do
		 response.should render_template(:index)
	end

end
