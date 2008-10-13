class AdvancedFileStore < ActiveSupport::Cache::FileStore
  

  private

  def real_file_path(name)
    @cache_path + '/' + File.join(*Digest::MD5.hexdigest(name).scan(/(.{2})(.{2})(.{2})(.*)/)) + '.cache'
  end

end
