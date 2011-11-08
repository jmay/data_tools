class IO
  def unmarshal
    Marshal.load(self)
  end
end
