require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require "json"

describe "File Import" do
  it "imports CSV" do
    f = File.open(File.dirname(__FILE__) + "/../tmp/hrhead.csv")
    # sio = f.import.csvme(StringIO.new, ['Person Phone GUID', 'Person Address GUID'])
    # puts sio.string

    f.import.each_slice(3) do |slice|
      puts slice.extend(DataTools::ArrayOfHashes).pluck('Person Phone GUID', 'Person Address GUID').to_json
    end
  end

  it "import WSV" do
    f = File.open(File.dirname(__FILE__) + "/../tmp/visits.txt")
    recs = f.import(:format => :wsv, :datefields => {'admit_arrive_date' => '%Y-%m-%d'}).to_a
    recs.count.should == 99
    puts recs.sample
  end
end
