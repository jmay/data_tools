class Object
  def vconvert(rule)
    self && VMunger::Conversions.method(rule).call(self)
  end
end
