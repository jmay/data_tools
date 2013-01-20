module DataTools::Enumerator
  def csvme(io, fields, headers = fields)
    io.puts headers.to_csv
    each do |hash|
      io.puts hash.pluck(fields).to_csv
    end
    io
  end
end

class Enumerator
  include DataTools::Enumerator
end
