require_relative "spec_helper"

describe "Comparator" do
  def explode(name)
    name.split.sort.map(&:upcase)
  end

  before :all do
    names = [
      "michael g palmer",
      "francis l palmer",
      "michael palmer"
    ]
    @corpus = names.map {|name| explode(name)}
  end

  it "works 1" do
    c = Comparator.new
    matches = c.crunch(explode("michael palmer"), @corpus)
    matches.should == [explode("michael g palmer")]
  end
end
