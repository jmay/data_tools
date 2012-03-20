# MULTI-MATCHING via components
# go through all users
# group by distinct sets of components
# pick a (small) subset of component-keys, say <10.  Maybe random sample?
# build a set of matching rules
# run the subset * the full corpus * the matching rules

class Comparator
  def initialize(corpus)
    @corpus = corpus
  end

  def crunch(record)
    (@corpus - [record]).reduce([]) do |matches,candidate|
    # @corpus.delete_if{|r| r == record}.reduce([]) do |matches,candidate|
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

  # must have at least 2 long (non-initial-only) components in each
  # those long parts must be identical
  # only one of the names can have any initials
  def missing_initials(a,b)
    longnames_a = a.select {|s| s.length > 1}
    longnames_b = b.select {|s| s.length > 1}
    inits_a = a.select {|s| s.length == 1}
    inits_b = b.select {|s| s.length == 1}

    longnames_a.count >= 2 && longnames_b.count >= 2 && longnames_a == longnames_b && (inits_a.empty? || inits_b.empty?)
  end

  # must have at least 1 long (non-initial-only) component in each
  # those long parts must be identical
  # all initials should correspond to non-matched longnames in the other input
  def matching_initials(a,b)
    longnames_a = a.select {|s| s.length > 1}
    longnames_b = b.select {|s| s.length > 1}
    inits_a = a.select {|s| s.length == 1}
    inits_b = b.select {|s| s.length == 1}

    return false unless longnames_a.count >= 1 && longnames_b.count >= 1

    unmatched_longnames_a = longnames_a - longnames_b
    unmatched_longnames_b = longnames_b - longnames_a
    unmatched_inits_a = unmatched_longnames_a.map {|s| s[0]}
    unmatched_inits_b = unmatched_longnames_b.map {|s| s[0]}

    inits_a == unmatched_inits_b && inits_b == unmatched_inits_a
  end
end
