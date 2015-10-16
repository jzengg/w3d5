require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'
# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # defaults fails when passed a symbol
    defaults = {
      foreign_key: "#{name.to_s.underscore}_id".to_sym,
      primary_key: :id,
      class_name: "#{name.to_s.camelize}"
    }
    attributes = defaults.merge(options)

    attributes.each do |key, value|
      sendable = "#{key}=".to_sym
      self.send(sendable, value)
    end


  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      foreign_key: "#{self_class_name.to_s.underscore}_id".to_sym,
      primary_key: :id,
      class_name: "#{name.to_s.camelize.singularize}"
    }
    # byebug
    attributes = defaults.merge(options)

    attributes.each do |key, value|
      sendable = "#{key}=".to_sym
      self.send(sendable, value)
    end

  end

end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})

    options = BelongsToOptions.new(name, options)

    define_method(name) do
      return nil if self.send(options.foreign_key).nil?

      results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{options.table_name}
      WHERE
        #{options.table_name}.#{options.primary_key} = #{self.send(options.foreign_key)}
      SQL

      options.model_class.new(results.first)
    end

    # class User < AR:BASE
    #   belongs_to :country, class_name: "Country"
    #   opts #=> class_name: Country, foreign_key: :country_id, primary_key: :id
    #   u = User.new(country_id: 1)
    #   u.country
    #   SELECT
    #     *
    #   FROM
    #     countries
    #     #{opts.class.table_name}
    #   WHERE
    #     id = 1
    #     id = country_id
    #     #{opts.primary_key} = #{self.send(opts.foreign_key)}
    #     self.country_id #-> 1
    #     opts.foreign_key

  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    define_method(name) do
      # byebug
      # return nil if self.send(options.foreign_key).nil?

      results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{options.table_name}
      WHERE
        #{options.table_name}.#{options.foreign_key} = #{self.send(options.primary_key)}
      SQL
      results.map { |attributes| options.class_name.constantize.new(attributes)}

    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
