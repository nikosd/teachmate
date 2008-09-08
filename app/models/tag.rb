class Tag < ActiveRecord::Base
	
	has_many :teach_taggings
	has_many :learn_taggings

end
