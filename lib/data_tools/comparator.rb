class Comparator
  def crunch(record, corpus)
    corpus.delete_if{|r| r == record}.reduce([]) do |matches,candidate|
      if evaluate(record, candidate)
        matches << candidate
      end
      matches
    end
  end

  def evaluate(record, candidate)
    [:missing_initials].each do |rule|
      return true if send(rule, record, candidate)
    end
    false
  end

  # don't need an 'identical' test - assuming that the input record does not appear in the corpus
  # def identical(a,b)
  #   a == b
  # end

  # ignore anything with just initials
  # must have at least 2 long components in each
  # those long parts must be identical
  def missing_initials(a,b)
    longnames_a = a.select {|s| s.length > 1}
    longnames_b = b.select {|s| s.length > 1}

    longnames_a.count >= 2 && longnames_b.count >= 2 && longnames_a == longnames_b
  end

end
