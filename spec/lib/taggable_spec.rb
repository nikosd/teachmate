require File.dirname(__FILE__) + '/../spec_helper'
require 'taggable'

module Taggable::InstanceMethods
	public :join_tags_to_string, :split_tags_string
end

describe Taggable::InstanceMethods do

  before(:each) do

		#################################
		# not sure we really need this
		# ###############################
		tag = mock(Tag)
		tag.should_receive(:string).any_number_of_times.and_return('tag_string')
		tagging = mock("Tagging")
		tagging.should_receive(:tag).any_number_of_times.and_return(tag)
		taggings_arr = mock("TaggingsArr")
		taggings_arr.should_receive(:delete_all).any_number_of_times
		taggings_arr.should_receive(:map).any_number_of_times.and_return(tagging)
		#################################
		#################################

    @taggable = mock(Taggable)
		@taggable.should_receive(:cute_taggings).any_number_of_times.and_return(taggings_arr)
		@taggable.should_receive(:cute_tags).any_number_of_times.and_return(tag, tag, tag)
		@taggable.extend(Taggable::InstanceMethods)

    @simple_tagsLine = "tag1, tag2, tag3,some tag with spaces"
    @complicated_tagsLine = ",tag1,, tag2  ,0tag3,    some tag with spaces,"
    @tagsLine_with_newlines = "tag1, tag2, \n tag3\n, tag4"
    @tagRegExp = /\A((\w+\s)+\w+|\w+)\Z/


  end

	it "should split a simple tags line" do
		Taggable::ClassMethods.split_tags_string(@simple_tagsLine).each {|tag| tag.should have_text(@tagRegExp)}
	end

	it "should split a complicated tags line" do
		@taggable.split_tags_string(@complicated_tagsLine).each {|tag| tag.should have_text(@tagRegExp)}
	end

  it "should split a tags line with new line symbols" do
    @taggable.split_tags_string(@tagsLine_with_newlines).should == ['tag1', 'tag2', 'tag3', 'tag4']
  end

	it "should join a tags array into a single line" do
		tagsarr = @taggable.split_tags_string(@complicated_tagsLine).map {|t| Tag.new(:string => t)}
		@taggable.join_tags_to_string(tagsarr).should == "tag1, tag2, 0tag3, some tag with spaces"
	end


end
