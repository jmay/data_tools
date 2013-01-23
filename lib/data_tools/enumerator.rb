module DataTools::Enumerator
  def csvme(outputstream, fields, headers = fields)
    outputstream.puts headers.to_csv
    each do |hash|
      outputstream.puts hash.pluck(fields).to_csv
    end
    outputstream
  end
end

class Enumerator
  include DataTools::Enumerator
end
