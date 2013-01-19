module DataTools::IO
  def unmarshal
    Marshal.load(self)
  end

  def headers
    @import_headers ||= @import_options[:headers] || behead
  end

  def parseline(line)
    line.chomp.split(header_delim)
  end

  def import_options
    @import_options ||= {
      junkwords: []
    }
  end

  def configure_import(options)
    import_options.merge!(options)
  end

  def import(opts = {}) # expects a block
    configure_import(opts)
    headers = opts[:headers] || parseline(readline)
    each_line do |line|
      rec = Hash[headers.zip(parseline(line))].extend DataTools::Hash
      yield rec.cleanse
    end
  end

end

class IO
  include DataTools::IO
end
