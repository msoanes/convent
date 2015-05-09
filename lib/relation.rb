class Relation
  def initialize(class_name, query_hash = nil)
    @class_name = class_name

    @query_hash = query_hash || {
      select: '*',
      from: model_class.table_name,
    }
  end

  def method_missing(method_name, *args)
    [].methods.include?(method_name) ? results.send(method_name, *args) : super
  end

  # Query methods should return a dup of self

  def where!(params)
    @query_hash[:where] ||= {}
    params.each do |key, value|
      @query_hash[:where][key] = value
    end
    self
  end

  def where(params)
    deep_dup.where!(params)
  end

  def limit!(num)
    @query_hash[:limit] = num
    self
  end

  def limit(num)
    deep_dup.limit!(num)
  end

  def count!
    @query_hash[:select] = 'COUNT(*) as count'
    execute.first['count']
  end

  def count
    deep_dup.count!
  end

  def order!(params)
    @query_hash[:order] ||= {}
    params.each do |param, asc_or_desc|
    end
  end

  def order
    deep_dup.order!
  end

  def length
    count
  end

  private

  def model_class
    @class_name.constantize
  end

  def build_query
    query_components = [
      select_part,
      from_part,
      where_part,
      limit_part
    ].join(" ")
  end

  def select_part
    "SELECT #{@query_hash[:select]}"
  end

  def from_part
    "FROM #{@query_hash[:from]}"
  end

  def where_part
    return '' if @query_hash[:where].nil? || @query_hash[:where].empty?
    where_line = @query_hash[:where].map { |k, _| "#{k} = ?" }.join(' AND ')
    "WHERE #{where_line}"
  end

  def limit_part
    return '' unless @query_hash.key?(:limit)
    "LIMIT #{@query_hash[:limit]}"
  end

  def params
    param_array = []
    param_array += @query_hash[:where].values unless @query_hash[:where].nil?
  end

  def results
    p build_query if @results.nil?
    @results ||= model_class.parse_all(execute)
  end

  def execute
    DBConnection.execute(build_query, *params)
  end

  def deep_dup
    new_params = @query_hash.deep_dup
    Relation.new(@class_name, new_params)
  end
end

class Hash
  def deep_dup
    new_hash = {}
    self.each do |k, v|
      begin
        if k.respond_to?(:deep_dup)
          k_dup = k.deep_dup
        elsif k.respond_to?(:dup)
          k_dup = k.dup
        end
      rescue TypeError
        k_dup = k
      end

      begin
        if v.respond_to?(:deep_dup)
          v_dup = v.deep_dup
        elsif v.respond_to?(:dup)
          v_dup = v.dup
        end
      rescue TypeError
        v_dup = v
      end

      new_hash[k_dup] = v_dup
    end
    new_hash
  end
end
