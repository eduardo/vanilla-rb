require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe Vanilla::Renderers::Base do
  describe "in general" do
    before(:each) do
      create_snip(:name => "test", :content => "content content", :part => "part content")
    end

    it "should render the contents part of the snip as it is" do
      response_body_for("/test").should == "content content"
    end
  
    it "should render the specified part of the snip" do
      response_body_for("/test/part").should == "part content"
    end
  
    it "should include the contents of a referenced snip" do
      create_snip(:name => "snip_with_inclusions", :content => "loading {test}")
      response_body_for("/snip_with_inclusions").should == "loading content content"
    end
  
    it "should perform snip inclusion when rendering a part" do
      create_snip(:name => "snip_with_inclusions", :content => "other content", :part => "loading {test}")
      response_body_for("/snip_with_inclusions/part").should == "loading content content"
    end
  
    it "should include other snips using their renderers" do
      create_snip(:name => "including_snip", :content => "lets include {another_snip}")
      create_snip(:name => "another_snip", :content => "blah", :render_as => "Bold")
      response_body_for("/including_snip").gsub(/\s+/, ' ').should == "lets include <b>blah</b>"
    end
  end
  
  describe "when trying to include a missing snip" do
    it "should return a string describing the missing snip" do
      create_snip(:name => 'blah', :content => 'include a {missing_snip}')
      response_body_for("/blah").should == "include a [snip 'missing_snip' cannot be found]"
    end
  end
end