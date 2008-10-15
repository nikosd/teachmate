module SearchHelper

	def show_tags(user, tagtype)
		tags = []
    tags_matched = []
		@search.tags.each do |tag|
			tag.send("#{tagtype.to_s}_taggings").each do |tagging|
				if tagging.user_id == user.id  
          tag.string = tag.string.slice(0..24) + '...' if tag.string.length > 25
          if @search.send("#{tagtype.to_s}_tags").include?(tag)
            tags_matched << "<strong>#{tag.string}</strong>" unless tags_matched.size > 10
          else
            tags << tag.string unless tags.size > 10
          end
					break
				end
			end
		end
    
    result =  tags_matched.concat(tags)
    more = ', [...]' if result.size > 10 
    "#{result.slice(0..9).join(', ')} #{more}"
	end

end
