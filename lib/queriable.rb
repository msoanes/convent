module Queriable
  def build_query
    components = @query_hash.keys.map { |component| send("#{component}_line") }
    components.flatten.compact.join(' ')
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
      selected_cols_arr = []
      @query_hash[:select].each do |column|
        unless column.is_a?(Hash)
          selected_cols_arr << "#{column}"
        else
          selected_cols_arr += column.map { |table, col| "#{table}.#{col}" }
        end
      end
      selected_cols = selected_cols_arr.join(', ')
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
    "LIMIT ?" unless @query_hash[:limit].nil?
  end

  def offset_line
    "OFFSET ?" unless @query_hash[:offset].nil? || @query_hash[:limit].nil?
  end

  def join_line
    return nil if @query_hash[:join].nil?
    joins_arr = @query_hash[:join].map do |assoc|
      options = class_model.instance_variable_get("@#{assoc}_options")
      assoc_table, local_table = options.table_name, class_model.table_name

      if options.class.name == 'BelongsToOptions'
        assoc_key, local_key = options.primary_key, options.foreign_key
      else
        assoc_key, local_key = options.foreign_key, options.primary_key
      end
      join_str = "JOIN #{assoc_table} ON "
      join_str << "#{local_table}.#{local_key} = #{assoc_table}.#{assoc_key}"
      join_str
    end
    joins_arr
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
