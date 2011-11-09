# keys can be anything
# values are always arrays

class HashOfArrays < Hash
  def append(hash2)
    (self.keys | hash2.keys).inject({}) {|h,k| h[k] = Array(self[k]) + Array(hash2[k]); h}
  end

  def coalesce(key1, args)
    key2 = args[:into] or raise "usage: coalesce(key1, :into => key)"
    self[key2] += self[key1]
    delete(key1)
  end
end
