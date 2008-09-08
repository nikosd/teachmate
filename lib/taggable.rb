class ActiveRecord::Base
  def self.acts_as_taggable
    include Taggable::InstanceMethods
  end
end

module Taggable

	module ClassMethods
	
		def self.split_tags_string(s)
			(s || "").sub(/^[,\s]+/,'').sub(/[,\s]+$/,'').gsub(/,+/,',').split(/\s*,\s*/)
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

