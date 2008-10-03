module UsersHelper

	def age(user, currdate=Date.today)
		if user.birthdate
			birthdate = user.birthdate
			#TODO: needs workaround for [2001-01-03 - 2004-02-29] case
			age = (currdate.year - birthdate.year) + ((currdate.month - birthdate.month) + ((currdate.day - birthdate.day) < 0 ? -1 : 0) < 0 ? -1 : 0)
			"#{age} years"
		end
	end

	def location(user)
		string = [user.city, user.region, user.country].map {|i| i if !i.nil? && !i.empty?}.compact.join(', ')
		"<span class=\"gray1\">from</span> #{string}" if !string.empty?
	end

  def location_string(options=[])
    if options.empty? and @user
      options = [@user.city, @user.region, @user.country]
    end
    options.delete_if {|option| option.blank?}
    return options.join(', ') unless options.empty?
    nil
  end

  def get_value_of(user, method)
    result = user.send(method) if @user
    return result if result 
  end

	def full_name(user)
		if user.first_name == nil && user.last_name == nil
			"user id #{user.id}"
		else fullname = [user.first_name, user.last_name].join(' ')
		end
	end

	def show_avatar(user)
		if user.avatar
      picture = "/images/avatars/#{user.avatar}"
    else
      picture="/images/avatar_default.jpg"
    end
		image_tag(picture, :class => 'avatar')
	end

  def profile_field(args)

    unless args[:value].blank?
      value = sanitize(args[:value], :tags => args[:allow_tags], :attributes => %w(href))
      value.gsub!(/\n/, '<br/>') if args[:br]
      return %Q{<tr>
        <td class="left">#{args[:title]}:</td>
        <td class="notes">
          #{value}
        </td>
      </tr>
      }
    end

  end

  def taglist(tags, type)
    tags.map do |t|
		  link_to(h(t.string), :controller => :search_proxy, :action => :index, :tag => t.string, :tag_type => type.to_s)
		end.join(', ')
  end

  def edit_only
    yield if params[:action] == 'edit'
  end

  def caption(field, text)
    unless error_message_on(:user, field).empty?
      t = error_message_on(:user, field)
    else
      t = text
    end
    "<small>#{t}</small>"
  end

  def form_error
    render(:partial => 'form_error') if flash[:error] or !@user.errors.empty?
  end

  def my_profile?
    true if current_logged_in == params[:id].to_i
  end

end
