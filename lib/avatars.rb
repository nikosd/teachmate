module Avatars

  def self.included(base)
    base.class_eval do
      attr_accessor :delete_avatar
      before_save :save_avatar
    end
  end

	def avatar=(f)

		require 'RMagick'
		#trying to read the image
		begin
			f.rewind
			@avatar_file = Magick::Image.from_blob(f.read).first
			#err if not an image
		rescue => e
			logger.info e  
			@avatar_file = nil
		end
	end

  
  private

	def generate_avatar_filename
    require 'string_generator'
    self.extend(StringGenerator)
    
    @avatar_storing_path = File.join(*Digest::MD5.hexdigest(Time.now.to_s).scan(/(.{2})(.{2})(.*)/))
    begin
      filename =  @avatar_storing_path + "/#{random_string(10)}.jpg"
    end while File.exists?("#{AVATARS_PATH}/#{filename}")
    filename
	end

  def save_avatar

    if @avatar_file
      delete_avatar_file
      @avatar_file.crop_resized!(50, 50) if (@avatar_file.rows > 50 || @avatar_file.columns > 50)
      write_attribute(:avatar, generate_avatar_filename)
      FileUtils.mkdir_p("#{AVATARS_PATH}/#{@avatar_storing_path}")
      @avatar_file.write("#{AVATARS_PATH}/#{avatar}")
    else
      if @delete_avatar
        delete_avatar_file
        write_attribute(:avatar, nil)
     end
    end
  end

  def delete_avatar_file
    if avatar and File.exists?("#{AVATARS_PATH}/#{avatar}")
      File.delete("#{AVATARS_PATH}/#{avatar}") 
    end
  end



end
