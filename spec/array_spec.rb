require_relative "spec_helper"

describe "DataTools Array extensions" do
  before(:each) do
    @a = [
      {:name => "bob", :city => "sunnyvale"},
      {:name => "phil", :city => "mountain view"}
    ]
  end

  it "can do gymnastics" do
    3.should == 3
  end

  it "can handle rules" do
    @a.extend DataTools::Rules
    rules = [
      {:input => :name, :output => :upname, :rule => lambda {|x| x.upcase}},
      {:input => :city, :output => :ytic, :rule => lambda {|x| x.reverse}}
    ]
    @a.enhance!(:rules => rules)
    @a.should == [
      {:name => "bob", :city => "sunnyvale", :upname => "BOB", :ytic => "elavynnus"},
      {:name => "phil", :city => "mountain view", :upname => "PHIL", :ytic => "weiv niatnuom"}
    ]
  end

  # pending "isn't ready yet" do
  #   4.should == 5
  # end
end
