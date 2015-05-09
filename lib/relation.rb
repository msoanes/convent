class Relation
  def initialize(class_name, query_hash = nil)
    @class_name = class_name
    @query_hash = query_hash || { select: '*', from: class_model.table_name }
  end

  def method_missing(name, *args)
    [].methods.include?(name) ? results.send(name, *args) : super
  end

  private

  def class_model
    @class_name.constantize
  end

  def results
    @results ||= execute_query
  end

  def build_query
    "SELECT #{@query_hash[:select]} FROM #{@query_hash[:from]}"
  end

  def params
  end

  def execute_query
    class_model.parse_all(DBConnection.execute(build_query, params))
  end
end
