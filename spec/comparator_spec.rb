require_relative "spec_helper"

describe "Comparator" do
  def explode(name)
    name.split.map(&:upcase).sort
  end

  def try(rule, name1, name2)
    @comp.send(rule, explode(name1), explode(name2)).should be_true
  end

  def bust(rule, name1, name2)
    @comp.send(rule, explode(name1), explode(name2)).should be_false
  end

  before :all do
    names = [
      "michael g palmer",
      "francis l palmer",
      "michael palmer"
    ]
    corpus = names.map {|name| explode(name)}
    @comp = Comparator.new(corpus)
  end

  it "finds names that match without initials" do
    try(:missing_initials, "michael palmer", "michael g palmer")
    try(:missing_initials, "michael palmer", "Q michael palmer")
    try(:missing_initials, "michael palmer", "Michael N Palmer x")
    bust(:missing_initials, "michael palmer", "Michael P")
    bust(:missing_initials, "michael palmer", "Michael John Palmer")

    matches = @comp.crunch(explode("michael palmer"))
    matches.should == [explode("michael g palmer")]
    matches = @comp.crunch(explode("palmer michael"))
    matches.should == [explode("michael g palmer")]
    matches = @comp.crunch(explode("michael g palmer"))
    matches.should == [explode("michael palmer")]
  end

  it "finds names that match initials to names" do
    try(:matching_initials, "fred jones", "f jones")
    try(:matching_initials, "fred jones", "jones f")
    try(:matching_initials, "fred jones", "fred j")
    try(:matching_initials, "fred xavier jones", "fred x jones")
    try(:matching_initials, "fred xavier jones", "xavier jones f")
    bust(:matching_initials, "fred xavier jones", "fred jones")
    bust(:matching_initials, "fred xavier jones", "fred q jones")
    bust(:matching_initials, "fred x jones", "fred q jones")
    bust(:matching_initials, "fred xavier jones", "homer simpson")
  end
end
