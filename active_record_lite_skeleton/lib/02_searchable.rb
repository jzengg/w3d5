require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map { |key| "#{key} = ? "}.join("AND ")

    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
      SQL
      
       results.map do |result|
         self.new(Hash[result.map{ |k, v| [k.to_sym, v] }])
       end
  end

end

class SQLObject
  extend Searchable

end
