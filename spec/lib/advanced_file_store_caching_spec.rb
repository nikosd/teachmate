require File.dirname(__FILE__) + '/../spec_helper'

describe ActiveSupport::Cache do

  before(:each) do
    @cache = AdvancedFileStore.new("#{RAILS_ROOT}/public/cache")
    @name = 'views/localhost:3000/search?learn=cooking%2C+love+people&location=%2C%2C&teach=bass+guitar%2C+piano'
  end

  it "should say hello" do
    @cache.send(:real_file_path, @name).should have_text("#{@cache.cache_path}/#{File.join(*Digest::MD5.hexdigest(@name).scan(/(.{2})(.{2})(.*)/))}.cache")
  end

end
