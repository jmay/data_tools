require "ap"
require "set"
require "csv"
require "facets" # for Hash#delete_values

module VMunger
  def self.reload!
    $".grep(/vmunger/).each {|f| load(f)}
  end
end

[
  "version", "array", "hash", "object", "string", "symbol",
  "file", "io"
  "conversions", "transformations"
].each do |file|
    require File.dirname(__FILE__) + "/vmunger/#{file}"
end

$stderr.puts "# loaded #{__FILE__}"
