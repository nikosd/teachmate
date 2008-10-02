class ActiveRecord::Base
  def self.acts_as_taggable
    include Taggable::InstanceMethods
  end
end

module Taggable

	module ClassMethods
	
		def self.split_tags_string(s)
			x = (s || "").sub(/\A[,\s]+/,'').sub(/[,\s]+\Z/,'').gsub(/[\s\n]*,+[\s\n]*/,',').split(/,/)
		end

	end
  
  module InstanceMethods
		
		private

    def join_tags_to_string(tags)
      tags.map {|t| t.string}.join(", ")
    end

    def split_tags_string(s)
    	Taggable::ClassMethods.split_tags_string(s) 
    end


	end

end

