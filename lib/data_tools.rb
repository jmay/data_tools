require "ap"
require "set"
require "csv"
require "facets" # for Hash#delete_values

module DataTools
  def self.reload!
    $".grep(/data_tools/).each {|f| load(f)}
  end
end

[
  "version",
  "array", "hash",
  "array_of_hashes", "hash_of_arrays",
  "comparator",
  "object", "string", "symbol",
  "file", "io",
  "rules",
  "conversions", "transformations"
].each do |file|
    require File.dirname(__FILE__) + "/data_tools/#{file}"
end
