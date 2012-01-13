# intent is for classes with array-of-hash behavior to `include` this module, or for instances to `extend` it

module DataTools::Rules
  def enhance!(args)
    raise "missing :rules" unless args[:rules]
    each do |rec|
      args[:rules].each do |rule|
        runrule(rule, rec)
      end
    end
  end

  private

  def runrule(rule, data)
    begin
      code = code_for(rule[:rule])

      case rule[:input]
      when Array
        data[rule[:output]] = code.call(data.values_at(*rule[:input]))
      else
        data[rule[:output]] = code.call(data[rule[:input]]) unless data[rule[:input]].nil?
      end
    rescue Exception => e
      STDERR.puts "RULE #{rule[:rule]} FAILED: #{e.to_s} WITH INPUTS #{data.values_at(*rule[:input]).inspect}"
      raise
    end
  end

  def code_for(rule)
    case rule
    when Symbol
      DataTools::Conversions.method(rule)
    else
      rule
    end
  end
end
