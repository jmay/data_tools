class Object
  def vconvert(rule)
    self && DataTools::Conversions.method(rule).call(self)
  end
end
