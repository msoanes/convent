require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    col_names, = DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}
    LIMIT
      0
    SQL

    col_names.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method("#{column}") do
        attributes[column]
      end

      define_method("#{column}=") do |val|
        attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || name.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    SQL


    parse_all(results)
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    parse_all(DBConnection.execute(<<-SQL, id: id)).first
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        id = :id
      LIMIT
        1
    SQL
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end
      send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |col| send(col) }
  end

  def insert
    q_marks = (['?'] * self.class.columns.length).join(',')
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO #{self.class.table_name} (#{self.class.columns.join(',')})
      VALUES (#{q_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    setters = self.class.columns.map { |col| "#{col} = ?" }
    setters = setters.join(', ')
    DBConnection.execute(<<-SQL, *(attribute_values + [id]))
      UPDATE
        #{self.class.table_name}
      SET
        #{setters}
      WHERE
        id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
