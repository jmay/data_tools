require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "DataTools Array extensions" do
  before(:each) do
    @array = Array.new
  end

  it "uses can do gymnastics" do
    3.should == 3
  end

  pending "isn't ready yet" do
    4.should == 5
  end
end
