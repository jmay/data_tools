module DataTools::Array
  # turns an array-of-arrays into an array-of-hashes
  # the headers are used as names for the fields
  # OK for rows to have fewer fields than the header record, but must not be longer
  def hashify(headers = shift)
    # ignore leading/trailing whitespace in header labels
    headers.each {|hdr| hdr.strip! if hdr === String}
    select {|row| row.any?}.map do |row|
      raise "Row count mismatch: #{row}" if row.count > headers.count
      hash = {}
      row.zip(headers) do |v,k|
        # ignore any keys with missing values
        # remove leading/trailing whitespace from values
        hash[k] = v.strip unless v.blank?
      end
      hash
    end
  end

  # ARRAY OF SCALARS
  # apply an operation (block) to every member of the array
  # return the list of unique results
  # if there is just one result, convert to a scalar value
  def resolve(&block)
    values = map {|v| block.call(v)}.uniq
    values.count <= 1 ? values.first : values
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
end
