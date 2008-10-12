class AdvancedFileStore < ActiveSupport::Cache::FileStore
  

  private

  def real_file_path(name)

    # ensures meta file lies in the same dir as .cache file 
    suffix = '.cache'
    suffix = '.meta' if name.gsub!(/_meta\Z/, '')

    @cache_path + '/' + File.join(*Digest::MD5.hexdigest(name).scan(/(.{2})(.{2})(.{2})(.*)/)) + suffix
  end

end
