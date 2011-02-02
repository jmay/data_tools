class Hash
  # construct a hash of changes needed to convert from an original hash to the new set of values
  # keys in the original that do not appear in the new hash should appear in the diff with nil values
  # EXCEPT that *symbol* keys from the original that *do not appear* (a nil value means it still appears) in the new hash should be ignored
  def diffs_from(orig)
    (self.keys | orig.keys).inject({}) do |diffs,key|
      if key.is_a?(Symbol) && !self.include?(key)
        # ignore this
      elsif orig[key] != self[key]
        diffs[key] = self[key]
      end
      diffs
    end
  end

  # construct a key field for the has based on the list of fields provided
  # options:
  #   :strip (true/false, default = true): remove leading & trailing whitespace from each value
  #   :truncate (integer): set maximum length for each value; truncate BEFORE stripping
  def key_for(keyarray, opts = {})
    opts[:strip] = true unless opts.has_key?(:strip)
    meth = lambda do |k|
      v = self[k]
      v = v[0,opts[:truncate]] if opts[:truncate]
      v = v.strip if opts[:strip] && v.is_a?(String)
      v
    end
    this_key = keyarray.map(&meth) #{|k| self[k].strip}
    return nil if this_key.all? {|v| v.nil?}
    return this_key.first if this_key.count == 1 # turn single-field keys into single values, not arrays
    if opts[:delim]
      this_key.join(opts[:delim])
    else
      this_key
    end
  end

  # for a Hash where all the values are Arrays
  # hash2 should also be a hash of key/array pairs
  # find all the cases where keys appear in both source hashes
  def pair_off(hash2)
    pairs = {}
    each do |k,ary|
      if hash2[k] && hash2[k].any?
        pairs[k] = [ary, hash2[k]]
      end
    end
    pairs
  end

  # same as `pair_off`, except that it chooses the partner key by calling a block
  # rather than doing a strict comparison
  def pair_off_by(hash2, &block)
    pairs = {}
    each do |k,ary|
      k2 = block.call(k)
      if hash2[k2] && hash2[k2].any?
        pairs[k] = [ary, hash2[k2]]
      end
    end
    pairs
  end

  # destructive version of `#pair_off` above.
  # when matching keys are found, the keys are removed from both source hashes.
  def pair_off!(hash2)
    pairs = {}
    each do |k,ary|
      if hash2[k].any?
        pairs[k] = [ary, hash2[k]]
        delete(k)
        hash2.delete(k)
      end
    end
    pairs
  end

  def pair_off_by!(hash2, &block)
    pairs = {}
    each do |k,ary|
      k2 = block.call(k)
      if hash2[k2] && hash2[k2].any?
        pairs[k] = [ary, hash2[k2]]
        delete(k)
        hash2.delete(k2)
      end
    end
    pairs
  end

  def dumpme(filename)
    raise "#{filename} exists" if File.exists?(filename)
    File.open(filename, "w") {|f| f << Marshal.dump(self)}
  end

  # HASH OF ARRAYS
  def append(hash2)
    (self.keys | hash2.keys).inject({}) {|h,k| h[k] = Array(self[k]) + Array(hash2[k]); h}
  end

  # HASH OF HASHES
  # compare to another hash-of-hashes (aka changes, deltas, diffs)
  # report the changes between a current state and a future state (hash2)
  # each of the four sections (new elements, lost elements, unchanged elements, changes) is another hash-of-hashes
  def compare(hash2)
    newkeys = hash2.keys - self.keys
    lostkeys = self.keys - hash2.keys
    commonkeys = self.keys & hash2.keys

    unchanged = []
    changes = {}
    commonkeys.each do |k|
      if (diffs = hash2[k].diff(self[k])).any?
        changes[k] = diffs
      else
        unchanged << k
      end
    end

    {
      :new => hash2.slice(*newkeys),
      :lost => self.slice(*lostkeys),
      :unchanged => self.slice(*unchanged),
      :changes => changes
    }
  end

  # convert specified fields to integers
  def numify!(*keyarray)
    keyarray.each do |k|
      self[k] = self[k].to_i if self[k]
    end
    self
  end

  # ARRAY OF HASHES
  #     correlated(:with => correlation-hash, :by => key-field)
  # pull subset that have mappings in the correlation hash
  def correlated?(args = {})
    with = args[:with]
    through = args[:through]
    onkey = args[:onkey]

    my_keys = keys
    correlation_keys = through.keys

    mismatches = select do |k,h|
      this_match = h[onkey]
      should_match = through[k] && with[through[k]]
      this_match != should_match
    end
    unmatched = correlation_keys - my_keys
    mismatches | unmatched
    # should be any empty array
    # select {|h| args[:with][h.key_for(args[:by], :delim => nil)]}
  end

  # apply correlations
  #     correlate!(:with => hash2, :through => mapping-hash, :onkey => attribute-to-record-mapping-in)
  # replaces any existing correlations (the `:on` field will be set to nil where the key does not appear in the correlation hash)
  def correlate!(args = {})
    with = args[:with]
    through = args[:through]
    onkey = args[:onkey]
    raise "Missing argument" if args[:onkey].nil?
    each do |k,h|
      this_match = through[k] && with[through[k]]
      h[onkey] = this_match
    end
  end

  # remove all the keys that contain nil values (or specify a "nil" value for sources that fill in empty records with special nil placeholders)
  def nilify!(nilvalue = nil)
    each do |k,v|
      self.delete(k) if v == nilvalue
    end
  end
end
