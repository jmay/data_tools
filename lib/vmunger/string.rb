class String
  # identifying keys (strings) that represent hierarchical structures, with format "superkey:subkey"
  def splitkey?
    self =~ /:/
  end
  # we always interpret the first part as a symbol
  def superkey
    split(/:/, 2).first.to_sym
  end
  # for STRINGS we always interpret the last part as a string ("resource:name" translates to :resource => name)
  def subkey
    split(/:/, 2).last
  end
end
