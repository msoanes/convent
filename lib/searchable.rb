require_relative 'db_connection'
require_relative 'relation'

module Searchable
  def where(params)
    Relation.new(name).where(params)
  end
end
