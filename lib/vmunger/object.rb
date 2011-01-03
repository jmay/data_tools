class Object
  def vconvert(rule)
    self && ConversionsLibrary.method(rule).call(self)
  end
end
