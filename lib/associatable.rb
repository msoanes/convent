require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @class_name  = options[:class_name]  || name.to_s.camelcase.singularize
    @primary_key = options[:primary_key] || :id
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @class_name = options[:class_name]   || name.to_s.camelcase.singularize
    @primary_key = options[:primary_key] || :id
    @foreign_key = options[:foreign_key] ||
                   "#{self_class_name.underscore}_id".to_sym
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(name) do
      id = send(options.foreign_key)
      options.model_class.where(options.primary_key => id).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      id = send(options.primary_key)
      options.model_class.where(options.foreign_key => id)
    end
  end

  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]

    define_method(name) do
      through_table = through_options.table_name
      through_pk = through_options.primary_key
      through_fk = through_options.foreign_key
      through_class = through_options.model_class

      source_options = through_class.assoc_options[source_name]
      source_table = source_options.table_name
      source_fk = source_options.foreign_key
      source_pk = source_options.primary_key
      source_class = source_options.model_class

      source_class.parse_all(DBConnection.execute(<<-SQL, send(through_fk)))[0]
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_fk} = #{source_table}.#{source_pk}
        WHERE
          #{through_table}.#{through_pk} = ?
      SQL
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end
