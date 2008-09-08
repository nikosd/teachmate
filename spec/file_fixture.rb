module FileFixture
  def file_fixture(fixture_path, content_type, filename = nil)
    filename ||= fixture_path
    path = File.expand_path(RAILS_ROOT) + fixture_path
    t = Tempfile.new('temp_fixture');
    t.binmode
    FileUtils.copy_file(path, t.path)
    (class << t; self; end).class_eval do
      alias local_path path
      define_method(:original_filename) { filename }
      define_method(:content_type) { content_type }
      define_method(:empty?) {false}
    end
    return t
  end

  def clean_uploaded_files_dir!
    require 'fileutils' 
    require 'ftools' 
    puts "***** clean_uploaded_files_dir! *****"
    # TODO: put assets dir prefix into environment files
    files = Dir["#{TEST_FILES_ROOT}/**/*"].sort{|a,b| b.length <=> a.length }
    #files.each {|d| puts d}
    # rm_rf doesn't work on windows  
    # FileUtils.rm_rf(CONFIG[:public_test_dir] + "/*");
    File.rm_f(*files) 
  end
end
