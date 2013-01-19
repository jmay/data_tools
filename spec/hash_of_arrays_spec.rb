require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Hash of Arrays" do
  before(:each) do
    @hoa = {
      "one" => ["a", "b", "c"],
      "two" => ["d", "e"],
      "three" => ["f"]
    }
    @hoa.extend DataTools::HashOfArrays
  end

  it "coalesces" do
    @hoa.coalesce("one", :into => "three")
    @hoa.size.should == 2
    @hoa["three"].should == ["f", "a", "b", "c"]
  end
end
