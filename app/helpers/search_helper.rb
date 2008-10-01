module SearchHelper

	def show_tags(user, tagtype)
		tags = []
		@search.tags.each do |tag|
			tag.send("#{tagtype.to_s}_taggings").each do |tagging|
				if tagging.user_id == user.id
					tags << wrap_bold_if(tag.string, @search.send("#{tagtype.to_s}_tags").include?(tag)) 
					break
				end
			end
		end
		tags.join(', ')
	end

	private

	def wrap_bold_if(content, cond)
		if cond: %{<strong>#{content}</strong>}
		else content
		end
	end

end
