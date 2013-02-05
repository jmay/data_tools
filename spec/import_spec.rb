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
    recs.shuffle.take(5).each {|rec| rec.keys.count.should == 3}
  end

  it "recognizes dates and times" do
    f = File.open(File.dirname(__FILE__) + "/../tmp/timetest.txt")
    config = {
      :format => :tsv,
      :datefields => {'EDIT_DATE' => '%Y-%m-%d'},
      :timefields => {'EDIT_TIME' => '%Y-%m-%d %H:%M:%S'}
    }
    recs = f.import(config).to_a
    recs.count.should == 99
    dt = recs.first['EDIT_DATE']
    tm = recs.first['EDIT_TIME']
    dt.year.should == 2012
    dt.month.should == 11
    dt.day.should == 28
    tm.hour.should == 0
    tm.min.should == 40
    tm.sec.should == 32
  end
end
