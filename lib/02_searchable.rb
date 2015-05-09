require_relative 'db_connection'
require_relative 'relation'

module Searchable
  def all
    Relation.new(name)
  end

  def method_missing(method_name, *args)
    if Relation.public_instance_methods.include?(method_name) ||
       Array.public_instance_methods.include?(method_name)
      all.send(method_name, *args)
    else
      super
    end
  end
end
