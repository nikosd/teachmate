require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersHelper, "with unempty user fields" do

	fixtures :users

	before(:each) do
		@user = User.find_by_first_name('User1')
	end

	it "should correctly calculate and return age" do
		helper.age(@user, Date.parse("2008-06-17")).should == "22 years"
	end

	it "should return the right location string" do
		prefix = "<span class=\"gray1\">from</span> "
		helper.location(@user).should have_text("#{prefix}Санкт-Петербург, Северо-запад, Russia")
		
		#empty city
		helper.location(User.find_by_first_name('User2')).should have_text("#{prefix}Северо-запад, Russia")

		#empty region
		helper.location(User.find_by_first_name('User3')).should have_text("#{prefix}Санкт-Петербург, Russia")

		#empty country
		helper.location(User.find_by_first_name('User4')).should have_text("#{prefix}Санкт-Петербург, Северо-запад")

		#empty country and region
		helper.location(User.find_by_first_name('User5')).should have_text("#{prefix}Санкт-Петербург")

		#empty country and city
		helper.location(User.find_by_first_name('User6')).should have_text("#{prefix}Северо-запад")

		#empty city and region
		helper.location(User.find_by_first_name('User7')).should have_text("#{prefix}Russia")

	end

	it "should show user fullname" do
		helper.full_name(@user).should have_text("User1 Snitko")
	end

	it "should show user id, if there's no first_name and last_name entered" do
		@user.update_attributes(:first_name => "", :last_name => "")
		helper.full_name(@user).should have_text("user id 1")
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
