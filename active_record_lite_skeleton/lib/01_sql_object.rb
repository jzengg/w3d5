require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    columns = DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL
    columns.first.map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |column|
      set_column = "#{column}="

      define_method(column) { attributes[column] }
      define_method(set_column) { |value| attributes[column] = value }

    end

  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    hash_objects = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(hash_objects)
  end

  def self.parse_all(results)
    results.map { |attributes| self.new(attributes) }
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL
    return nil if results.empty?
    symbols = Hash[results.first.map{ |k, v| [k.to_sym, v] }]
    self.new(symbols)


  end

  def initialize(params = {})
    params.each do |attribute, value|
      unless self.class.columns.include?(attribute.to_sym)
        raise "unknown attribute '#{attribute}'"
      end
      self.attributes[attribute] = value
    end


  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |column| self.send(column) }
  end

  def insert
    col_names = self.class.columns.map(&:to_s)
    question_marks = ["?"] * col_names.length
    DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names.join(", ")})
      VALUES
        (#{question_marks.join(", ")})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    col_names = self.class.columns.map { |column| "#{column} = ?"}.join(", ")

    DBConnection.execute(<<-SQL, attribute_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_names}
      WHERE
        id = #{self.id}
    SQL
  end

  def save
    id.nil? ? insert : update
  end

end
