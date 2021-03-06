module DataTools::ArrayOfHashes
  # convert an array of hashes to a hash of the same hashes
  # where the key values are picked from the hashes
  # the keys can be single fields, or an array, or a list
  # options:
  #   :multi (boolean, default false): if true, allow multiple values per key; store values as an array for each key
  #   :first (boolean, default false): if true, when finding multiple values per key, store only the first and ignore the rest
  #   :truncate (integer): see `Hash#key_for`
  #
  def key_on(*keyarray)
    raise "Key(s) required" if keyarray.empty?
    opts = keyarray.last.is_a?(Hash) ? keyarray.pop : {}
    keyarray = keyarray.flatten

    memo = opts[:multi] ? Hash.new {|h,k| h[k] = []} : Hash.new
    each do |hash|
      this_key = hash.key_for(keyarray, opts)
      raise "Missing value for #{keyarray} in record #{hash}" if this_key.nil?
      if opts[:multi]
        memo[this_key] << hash
      elsif opts[:first]
        # ignore this value if we already have one for this key
        if !memo.has_key?(this_key)
          memo[this_key] = hash
        end
      else
        raise "Found duplicate #{keyarray} in #{memo[this_key]} vs #{hash}" if memo.has_key?(this_key)
        memo[this_key] = hash
      end
      memo
    end
    memo.extend DataTools::HashOfArrays
    memo.default = nil
    memo
  end

  # shorthand for `Array#select {|hash| hash[...] && hash[...] ...}`
  # find all the members of the array where all the specified criteria are true
  def where(conditions)
    newhash = case conditions
    when Hash
      select do |record|
        conditions.map do |k,v|
          case v
          when Regexp
            record[k] =~ v
          when TrueClass
            !record[k].nil?
          when FalseClass
            record[k].nil?
          else
            record[k] == v
          end
        end.reduce(:&) # all tests must pass
      end
    when String,Symbol
      # just check for presence & non-nil value of specified key
      select {|record| record[conditions]}
    end
    newhash.extend DataTools::ArrayOfHashes
  end

  # are all the values for `key` defined and unique?
  def unique?(*keyarray)
    raise "Key(s) required" if keyarray.empty?
    keyarray = keyarray.flatten
    keys = map {|hash| hash.key_for(keyarray)}
    return false if keys.any?(&:nil?)
    keys.uniq.count == self.count
  end

  def unique_values_for(*keyarray)
    raise "Key(s) required" if keyarray.empty?
    keyarray = keyarray.flatten
    map {|hash| hash.key_for(keyarray)}.to_set
  end

  # assign unique IDs to every hash in the array
  # argument is the name of the field to use for the generated sequential key
  def count_off!(key = :key, start = 0)
    raise "Values exist for [#{key}]" if any?{|h| h[key]}
    each_with_index do |hash, i|
      hash[key] = i + start
    end
    self
  end

  def redundant(*keyarray)
    key_on(keyarray, :multi => true).select {|k,v| v.count > 1}
  end

  # combine a set of hashes into one
  # for each key, find all the distinct values from all the hashes
  # if there's one unique value, store the single value in key of the result
  # if there are multiple values, store them all as an array
  def coalesce
    allkeys = map {|h| h.keys}.flatten.uniq
    allkeys.reduce({}) do |memo,key|
      memo[key] = map {|h| h[key]}.compact.uniq
      memo[key] = memo[key].first if memo[key].count <= 1
      memo
    end
  end

  # apply the same resolution operation to every hash in the list
  def resolve_all(key, &block)
    map do |hash|
      hash = hash.dup
      hash[key] = hash[key].resolve(&block)
      hash
    end
  end

  # marshal (ruby-specific binary format) the contents of this structure to a file
  # fails if file exists
  def dumpme(filename)
    raise "#{filename} exists" if File.exists?(filename)
    File.open(filename, "w") {|f| f << Marshal.dump(self)}
  end
  # same as #dumpme but overwrites existing file
  def dumpme!(filename)
    File.unlink(filename) if File.exists?(filename)
    File.open(filename, "w") {|f| f << Marshal.dump(self)}
  end

  # # attempt to dump out contents of this array-of-hashes as CSV to named file
  # # fields is list of attribute names to write out
  # # options headers is public names for the fields
  # def csvme(filename, fields, headers = fields)
  #   CSV.open(filename, "wb") do |csv|
  #     csv << headers unless headers.nil?
  #     pluck(fields).each do |ary|
  #       csv << ary
  #     end
  #   end
  #   true
  # end

  def tsvme(filename, fields, headers = fields)
    File.open(target) do |output|
      output.puts headers.join("\t")
      pluck(fields).each do |ary|
        output.puts ary.join("\t")
      end
    end
    true
  end

  # What different keys appear in this collection of hashes?
  def allkeys
    each_with_object({}) do |h, memo|
      h.keys.each {|k| memo[k] += 1}
    end.keys
  end

  def metrics
    allkeys.reduce({}) do |m,k|
      values = self.map {|h| h[k]}
      m[k] = {
        :non_nil => values.compact.count,
        :nil => values.count - values.compact.count,
        :unique => values.uniq.count
      }
      if m[k][:unique] <= 10
        m[k][:values] = histogram(k)
      end
      m
    end
  end

  def numify!(*keyarray)
    each {|h| h.numify!(*keyarray)}
  end

  def nilify!(keyvalue)
    each {|h| h.nilify!(keyvalue)}
  end

  # return histogram of value distribution for the specified key: hash of value/count pairs
  def histogram(*args, &block)
    reduce(Hash.new(0)) do |hist, h|
      if block_given?
        v = yield(h)
      else
        v = h[args.first]
      end
      hist[v] += 1
      hist
    end
  end

  # hash slice for all the named attributes from each hashes in the array
  def subset(*keys)
    keys = keys.flatten
    map {|h| h.subset(keys) }
  end

  # pull out all the named attributes from the hashes in the array (into array-of-arrays)
  def pluck(*keys)
    keys = keys.flatten
    map {|h| h.pluck(keys)}
    # if keys.count > 1
    #   map {|h| keys.map {|k| h[k]}}
    # else
    #   map {|h| h[keys.first]}
    # end
  end

  # For each record, output a subset of the values as an array (suitable for passing to `#to_csv`)
  # supports hierarchical subkeys (e.g. :master:id or "master:name")
  def project(args)
    defaults = args[:defaults] || {}
    map do |h|
      args[:keys].map do |k|
        (k.splitkey? && (deref = h[k.superkey]) && deref[k.subkey]) || h[k] || defaults[k] || args[:nilvalue]
      end
    end
  end
end
