module ParsleyStoreHelpers
  def get_value(val)
    return nil if ['nil', 'null'].include? val 
    return val.to_i if val.to_i.to_s == val
    return true if val == 'true'
    return false if val == 'false'
  end
end


World(ParsleyStoreHelpers)
