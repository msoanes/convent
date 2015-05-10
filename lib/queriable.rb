module Queriable
  def build_query
    components = @query_hash.keys.map { |component| send("#{component}_line") }
    components.compact.join(' ')
  end

  def params
    return nil if @query_hash[:where].nil? || @query_hash[:where].empty?
    condition_params(:where)
  end

  def select_line
    "SELECT #{@query_hash[:select]}"
  end

  def from_line
    "FROM #{@query_hash[:from]}"
  end

  def where_line
    return nil if @query_hash[:where].nil? || @query_hash[:where].empty?

    condition_string = conditions(:where).flatten.join(' AND ')
    "WHERE #{condition_string}"
  end

  def conditions(line_sym)
    cond_arr = []
    @query_hash[line_sym].each do |key, value|
      if value.is_a?(Hash)
        value.each do |col, val|
          cond_arr << "#{key}.#{col} = ?"
        end
      else
        cond_arr << "#{key} = ?"
      end
    end
    cond_arr
  end

  def condition_params(line_sym)
    param_array = []
    @query_hash[line_sym].values.each do |val|
      if val.is_a?(Hash)
        param_array += val.values
      else
        param_array << val
      end
    end
    param_array
  end
end
