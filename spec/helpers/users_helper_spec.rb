require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersHelper, "with unempty user fields" do

	fixtures :users
  include UsersHelper

	before(:each) do
		@user = User.find_by_first_name('User1')
	end

	it "should correctly calculate and return age" do
		helper.age(@user, Date.parse("2008-06-17")).should == "22 years"
	end

  it "should display location" do
    location_string(['', '', '']).should be_nil
    location_string(['San-Francisco', '', '']).should have_text('San-Francisco')
    location_string(['San-Francisco', 'CA', '']).should have_text('San-Francisco, CA')
    location_string(['San-Francisco', 'CA', 'US']).should have_text('San-Francisco, CA, US')
  end

	it "should show user fullname" do
		helper.full_name(@user).should have_text("User1 Snitko")
	end

	it "should show user id, if there's no first_name and last_name entered" do
		@user.update_attributes(:first_name => "", :last_name => "")
		helper.full_name(@user).should have_text("user id 1")
	end

  it "should wrap urls with <a></a> tags" do
    string = "Hi, here's my blog http://blog.snitko.ru and here's my tiny little homepage http://snitko.ru
    I like google!"

    helper.wrap_urls(string).should have_text(
    'Hi, here\'s my blog <a href="http://blog.snitko.ru">http://blog.snitko.ru</a> and here\'s my tiny little homepage <a href="http://snitko.ru">http://snitko.ru</a>
    I like google!')
  end

end

describe UsersHelper, "with empty user fields" do

	before(:each) do
		@user = User.new(:birthdate => '')
	end

	it "should correctly calculate and return age" do
		helper.age(@user, Date.parse("2008-06-17")).should be_nil
	end

end
