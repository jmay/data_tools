require "ap"
require "set"
require "csv"
require "facets" # for Hash#delete_values

module DataTools
  def self.reload!
    $".grep(/data_tools/).each {|f| load(f)}
  end

  def DataTools.scour(s)
    case s
    when nil
      nil
    when String
      s2 = s.strip.gsub(/\s+/, ' ').gsub(/^"/, '').gsub(/"$/, '')
      if s2 =~ /^[\d]+(\.[\d]+){0,1}$/
        # looks numeric
        s2 = s2.to_i.to_s
      end
      (s2.empty? || import_options[:junkwords].include?(s2)) ? nil : s2
    when Numeric
      s.to_s
    else
      s.to_s
    end
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
