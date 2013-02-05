require "csv"

module DataTools::IO
  attr_reader :headers, :import_options

  def unmarshal
    Marshal.load(self)
  end

  def split(line)
    fields = case import_options[:format]
    when :tsv # tab-delimited
      line.split("\t")
    when :wsv # whitespace-delimited
      line.split
    when :qcq # quote-comma-quote (*not* the same as CSV)
      line.split('","')
    else # default is :csv
      line.parse_csv
    end

    fields.map {|f| DataTools.scour(f)}
  end

  def parseline(line)
    @linenumber += 1
    # remove leading and trailing line endings (CR or LF)
    # but NOT whitespace, because e.g. there could be leading or trailing blank fields delimited by tabs
    split(line.gsub(/^[\n\r]*|[\n\r]*$/, ''))
  end

  def import_options
    @import_options ||= {
      junkwords: [],
      datefields: {},
      timefields: {}
    }
  end

  def configure_import(options)
    import_options.merge!(options)
  end

  def line_to_record(line)
    Hash[headers.zip(parseline(line)).select {|k,v| !v.nil?}]
  end

  def import(opts = {}) # expects a block
    configure_import(opts)
    @linenumber = 0
    @headers = opts[:headers] || parseline(readline(opts[:rowsep] || $/))
    Enumerator.new do |yielder|
      self.each(opts[:rowsep] || $/) do |line|
        rec = line_to_record(line)
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
