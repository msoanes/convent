require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

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
end
