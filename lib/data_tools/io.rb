require "csv"

module DataTools::IO
  def unmarshal
    Marshal.load(self)
  end

  def headers
    @import_headers ||= @import_options[:headers] || behead
  end

  def split(line)
    case import_options[:format]
    when :tsv
      line.split("\t")
    when :qcq
      line.split('","')
    else # default is CSV
      line.parse_csv
    end
  end

  def parseline(line)
    split(line.chomp)
  end

  def import_options
    @import_options ||= {
      junkwords: [],
      datefields: {}
    }
  end

  def configure_import(options)
    import_options.merge!(options)
  end

  def import(opts = {}) # expects a block
    configure_import(opts)
    headers = opts[:headers] || parseline(readline)
    # warn "HEADERS ARE #{headers}"
    Enumerator.new do |yielder|
      self.each do |line|
        rec = Hash[headers.zip(parseline(line))]
        rec.extend DataTools::Hash
        yielder.yield rec.cleanse(import_options)
      end
      # need to emit anything to trigger a file-completed action? (such as pushing a batch to storage)
    end
  end
end

class IO
  include DataTools::IO
end
