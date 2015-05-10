module Queriable
  def build_query
    components = @query_hash.keys.map { |component| send("#{component}_line") }
    components.compact.join(' ')
  end

  def params
    return nil if @query_hash[:where].nil? || @query_hash[:where].empty?
    @query_hash[:where].values 
  end

  def select_line
    "SELECT #{@query_hash[:select]}"
  end

  def from_line
    "FROM #{@query_hash[:from]}"
  end

  def where_line
    return nil if @query_hash[:where].nil? || @query_hash[:where].empty?
    conditions = @query_hash[:where].keys.map { |col| "#{col} = ?" }
    "WHERE #{conditions.join(' AND ')}"
  end
end
