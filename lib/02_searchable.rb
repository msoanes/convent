require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_string = params.keys.map { |col| "#{col} = ?" }.join(' AND ')

    parse_all(DBConnection.execute(<<-SQL, *params.values))
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_string}
    SQL
  end
end

class SQLObject
  extend Searchable
end
