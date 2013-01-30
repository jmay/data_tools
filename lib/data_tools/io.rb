require "csv"

module DataTools::IO
  attr_reader :headers

  def unmarshal
    Marshal.load(self)
  end

  def split(line)
    fields = case import_options[:format]
    when :tsv
      line.split("\t")
    when :qcq
      line.split('","')
    else # default is :csv
      line.parse_csv
    end

    fields.map {|f| DataTools.scour(f)}
  end

  def parseline(line)
    @linenumber += 1
    split(line.strip)
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
    @linenumber = 0
    @headers = opts[:headers] || parseline(readline(opts[:rowsep] || $/))
    # warn "HEADERS ARE #{headers}"
    Enumerator.new do |yielder|
      self.each(opts[:rowsep] || $/) do |line|
        rec = Hash[headers.zip(parseline(line))]
        next if rec.empty? # silently ignore blank records
        rec.extend DataTools::Hash
        yielder.yield rec.cleanse(import_options.merge(:line => @linenumber))
      end
      # need to emit anything to trigger a file-completed action? (such as pushing a batch to storage)
    end
  end
end

class IO
  include DataTools::IO
end

ARGF.extend DataTools::IO

