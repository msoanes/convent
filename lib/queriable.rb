module Queriable
  def build_query
    components = @query_hash.keys.map { |component| send("#{component}_line") }
    components.compact.join(' ')
  end

  def params
  end

  def select_line
    "SELECT #{@query_hash[:select]}"
  end

  def from_line
    "FROM #{@query_hash[:from]}"
  end
end
