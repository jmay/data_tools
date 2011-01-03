class Symbol
  # identifying keys (strings) that represent hierarchical structures, with format :"superkey:subkey"
  def splitkey?
    to_s =~ /:/
  end
  # we always interpret the first part as a symbol
  def superkey
    to_s.split(/:/, 2).first.to_sym
  end
  # for SYMBOLS we always interpret the last part as a symbol (:"resource:id" translates to :resource => :id)
  def subkey
    to_s.split(/:/, 2).last.to_sym
  end
end
