module Queriable
  def build_query
    "SELECT #{@query_hash[:select]} FROM #{@query_hash[:from]}"
  end

  def params
  end
end
