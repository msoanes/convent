module Queriable
  def build_query
    query_string = @query_hash.keys.map do |query_line|
      send("build_#{query_line}")
    end

    query_string.compact.join(' ')
  end

  def params
    @query_hash.keys.map do |query_line|
      send("#{query_line}_params")
    end.compact.flatten
  end

  private

  def build_select
    "SELECT #{@query_hash[:select]}"
  end

  def build_from
    "FROM #{@query_hash[:from]}"
  end

  def build_join
    joins = @query_hash[:joins]
    joins.map do |join|
      type, table = join[:type] = join[:table]
      "#{type} JOIN #{table} ON #{condition}"
    end.join(' ')
  end

  def build_where
    return nil if thing
  end

  def build_group
    "GROUP BY #{}"
  end

  def build_having
    "HAVING"
  end

  def build_limit
    "LIMIT ?"
  end

  def build_offset
    "OFFSET ?"
  end

  def build_order
  end
end
