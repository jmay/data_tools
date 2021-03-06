module DataTools::Transformations
  # unraveling the hierarchical group membership structure in Microsoft Active Directory
  # expand the group information from MSAD "memberOf" fields
  # flatten the hierarchy, so each account records every group of which it is a member, even through sub-groups
  def self.expand_msad_groups(hashes)
    $stderr.puts "Analyzing #{hashes.size} Active Directory records"
    msad_accounts_by_dn = hashes.key_on('DN')
    $stderr.puts "Found #{msad_accounts_by_dn.size} distinct DN values"

    # expand the multi-valued memberOf field, and look up each group
    # WARNING: does not report any cases if the DN for the group does not appear in the hashes, will just leave a nil in the list
    hashes.each do |hash|
      hash[:memberof] = (hash['memberOf'] || '').split(';').map {|dn| msad_accounts_by_dn[dn]}
    end
    $stderr.puts "Expanded groups on #{hashes.select {|h| h[:memberof].any?}.size} records"

    membership_counts = hashes.map {|h| h[:memberof].size}.sum

    begin
      $stderr.puts "Found #{membership_counts} memberships, moving up membership hierarchy..."
      base_membership_counts = membership_counts
      hashes.each do |hash|
        hash[:memberof] |= hash[:memberof].map {|g| g[:memberof]}.flatten.uniq  
      end
      membership_counts = hashes.map {|h| h[:memberof].size}.sum
      # repeat until no further memberships are found
    end while membership_counts == base_membership_counts
  end

  # superseded by rules.rb
  # def self.enhance(args)
  #   h = args[:hash]
  #   args[:rules].each do |rule|
  #     self.runrule(rule, h)
  #   end
  #   h
  # end
  # 
  # def self.runrule(rule, data)
  #   begin
  #     if rule[:input].is_a?(Array)
  #       data[rule[:output]] = data.values_at(*rule[:input]).vconvert(rule[:rule])
  #     else
  #       data[rule[:output]] = data[rule[:input]].vconvert(rule[:rule])
  #     end
  #   rescue Exception => e
  #     STDERR.puts "RULE #{rule[:rule]} FAILED: #{e.to_s} WITH INPUTS #{data.values_at(*rule[:input]).inspect}"
  #     exit
  #   end
  # end
end
