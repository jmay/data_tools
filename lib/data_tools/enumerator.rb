module DataTools::Enumerator
  def csvme(outputstream, fields, headers = fields)
    outputstream.puts headers.to_csv
    each do |hash|
      outputstream.puts hash.pluck(fields).to_csv
    end
    outputstream.flush # otherwise missing rows might not get pushed out
    outputstream
  rescue Errno::EPIPE
    # output was closed, that's fine
  end

  def lazy_select(&block)
    Enumerator.new do |yielder|
      self.each do |val|
        yielder.yield(val) if block.call(val)
      end
    end
  end

  def lazy_map(&block)
    Enumerator.new do |yielder|
      self.each do |value|
        yielder.yield(block.call(value))
      end
    end
  end
end

class Enumerator
  include DataTools::Enumerator
end
