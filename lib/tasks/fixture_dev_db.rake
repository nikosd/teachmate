namespace :db do
	
	ENV['FIXTURES'] = "users,learn_taggings,teach_taggings,tags"
  
	desc "Raise an error unless the RAILS_ENV is development"
  task :check_environment do
    raise "Hey, development or test only you monkey!" if RAILS_ENV == 'production'
  end

	namespace :fixtures do
	task :delete => :environment do
			require 'active_record/fixtures'
			ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
			ENV['FIXTURES'].split(',').reverse.each do |fixture_name|
				ActiveRecord::Base.connection.update "DELETE FROM #{fixture_name}"
			end
		end
	end


  desc "Delete and load fixtures"
  task :prepare_search_fixtures => [
    'environment', 
    'db:check_environment', 
    'db:reset', 
		'db:load_search_fixtures'
    ]

	desc "Load fixtures for search query"
	task :load_search_fixtures => ['environment'] do
		names = IO.read("#{RAILS_ROOT}/spec/fixtures/names.txt").split(' ')
    good_usernames = names.slice(0..19)
    bad_usernames = names.slice(21..25)

		good_usernames.each { |name| User.create(:first_name => name, :last_name => "good_user",
		:learn_tags_string => 'bass guitar, piano, sports, kill all humans', :teach_tags_string => 'cooking, love people') }

		# This one creates user, who has only one of learn_tags
		# and, therefore, should not be included in search results
		User.create(:first_name => names[20], :last_name => "user_with_one_tag", :learn_tags_string => "bass guitar, piano, sports", :teach_tags_string => "cooking")

		bad_usernames.each { |name| User.create(:first_name => name, :last_name => "bad_user", :learn_tags_string => 'travelling') }
	end

end
