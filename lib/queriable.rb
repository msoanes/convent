module Queriable
  def build_query
    components = @query_hash.keys.map { |component| send("#{component}_line") }
    components.compact.join(' ')
  end

  def params
    param_arr = []
    param_arr += condition_params(:where) unless @query_hash[:where].nil?
    param_arr << @query_hash[:limit] unless @query_hash[:limit].nil?
    param_arr << @query_hash[:offset] unless @query_hash[:offset].nil?
    param_arr
  end

  def select_line
    if @query_hash[:select].nil?
      selected_cols = "#{class_model.table_name}.*"
    else
      selected_cols = @query_hash[:select].map(&:to_s).join(', ')
    end
    "SELECT #{selected_cols}"
  end

  def from_line
    "FROM #{@query_hash[:from]}"
  end

  def where_line
    return nil if @query_hash[:where].nil? || @query_hash[:where].empty?

    condition_string = conditions(:where).flatten.join(' AND ')
    "WHERE #{condition_string}"
  end

  def limit_line
    'LIMIT ?' unless @query_hash[:limit].nil?
  end

  def offset_line
    'OFFSET ?' unless @query_hash[:offset].nil? || @query_hash[:limit].nil?
  end

  def conditions(line_sym)
    cond_arr = []
    @query_hash[line_sym].each do |key, value|
      if value.is_a?(Hash)
        value.each { |col, _| cond_arr << "#{key}.#{col} = ?" }
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
