require_relative 'queriable'

class Relation

  def self.dup_hash(hsh)
    result = {}
    hsh.each do |key, val|
      result[gen_dup(key)] = gen_dup(val)
    end

    result
  end

  def self.gen_dup(item)
    if item.is_a?(Hash)
      dup_hash(item)
    else
      item.dup
    end
  rescue
    item
  end

  def initialize(class_name, query_hash = nil)
    @class_name = class_name
    @query_hash = query_hash || {
      select: nil,
      from: class_model.table_name,
      where: nil,
      limit: nil,
      offset: nil
    }
  end

  def method_missing(name, *args)
    [].methods.include?(name) ? results.send(name, *args) : super
  end

  def selects(*params)
    deep_dup.selects!(*params)
  end

  def selects!(*params)
    if @query_hash[:select].nil?
      @query_hash[:select] = params
    else
      @query_hash[:select] += params
    end

    self
  end

  def where(params)
    deep_dup.where!(params)
  end

  def where!(params)
    @query_hash[:where] ||= {}
    params.each do |column, value|
      @query_hash[:where][column] = value
    end

    self
  end

  def limit(num)
    deep_dup.limit!(num)
  end

  def limit!(num)
    @query_hash[:limit] = num

    self
  end

  def offset(num)
    deep_dup.offset!(num)
  end

  def offset!(num)
    @query_hash[:offset] = num

    self
  end

  private

  include Queriable

  def class_model
    @class_name.constantize
  end

  def results
    @results ||= execute_query
  end

  def execute_query
    class_model.parse_all(DBConnection.execute(build_query, params))
  end

  def deep_dup
    Relation.new(@class_name, self.class.dup_hash(@query_hash))
  end
end
