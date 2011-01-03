require "ap"
require "set"
require "csv"
require "facets" # for Hash#delete_values

require "vmunger/array"
require "vmunger/conversions"
require "vmunger/hash"
require "vmunger/object"
require "vmunger/string"
require "vmunger/symbol"
require "vmunger/transformations"

module VMunger
  def reload!
    $".grep(/vmunger/).each {|f| load(f)}
  end

  def unmarshal(file)
    Marshal.load(File.read(file))
  end
end

$stderr.puts "# loaded #{__FILE__}"
