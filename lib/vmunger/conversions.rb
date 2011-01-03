module VMunger::Conversions
  def self.noop(value)
    value
  end

  # MSAD uses INT64 (8 bytes) for lastLogon, lastLogonTimestamp, accountExpires
  def self.msad_long_timestamp(value)
    case value.to_i
    when 0, 0x7FFFFFFFFFFFFFFF
      nil
    else
      DateTime.new(1601, 1, 1) + value.to_i/(60.0 * 10000000 * 1440)
    end
  end

  def self.readable_timestamp(value)
    DateTime.parse(value)
  end

  def self.first_ou(value)
    (ou = value.split(',').select{|s| s =~ /^OU=/}.first) && ou.split('=').last
  end

  def self.msad_active_account(value)
    value.to_i & 2 == 0
  end

  def self.datestr(value)
    value.strftime("%m/%d/%Y")
  end

  def self.max_datestr(values)
    (dt = values.compact.max) && dt.strftime("%m/%d/%Y")
  end
end
