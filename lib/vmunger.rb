require "ap"
require "set"
require "csv"
require "facets" # for Hash#delete_values

module VMunger
  def self.reload!
    $".grep(/vmunger/).each {|f| load(f)}
  end

  def self.unmarshal(file)
    Marshal.load(File.read(file))
  end
end

require File.dirname(__FILE__) + "/vmunger/version"
require File.dirname(__FILE__) + "/vmunger/array"
require File.dirname(__FILE__) + "/vmunger/conversions"
require File.dirname(__FILE__) + "/vmunger/hash"
require File.dirname(__FILE__) + "/vmunger/object"
require File.dirname(__FILE__) + "/vmunger/string"
require File.dirname(__FILE__) + "/vmunger/symbol"
require File.dirname(__FILE__) + "/vmunger/transformations"

$stderr.puts "# loaded #{__FILE__}"
