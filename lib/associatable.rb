module Associatable

  def assoc_options
    @assoc_options ||= {}
  end

  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      key_value = self.send(options.foreign_key)

      options.model_class.where(options.primary_key => key_value).first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, options)
    define_method(name) do
      options = self.class_assoc_options[name]
      key_value = self.send(options.primary_key)

      options.model_class.where(options.foreign_key => key_value)
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      key_value = self.send(through_foreign)
      results = DBConnection.execute(<<-SQL, key_value)
        SELECT
          #{source_options.table_name}.*
        FROM
          #{through_options.table_name}
        JOIN
          #{source_options.table_name}
        ON
          #{through_options.table_name}.#{source_options.foreign_key} = #{source_options.table_name}.#{source_options.primary_key}
        WHERE
          #{through_options.table_name}.#{through_options.primary_key} = ?
      SQL
    end
  end

  def has_many_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_table = through_options.table_name
      through_primary = through_options.primary_key
      through_foreign = through_options.foreign_key

      source_table = source_options.table_name
      source_primary = source_options.primary_key
      source_foreign = source_options.foreign_key

      table_name = self.class.table_name

      results = DBConnection.execute(<<-SQL, self.id)
        SELECT
          #{source_table}.*
        FROM
          #{source_table}
        JOIN
          #{through_table}
        ON
          #{source_table}.#{source_primary} = #{through_table}.#{source_foreign}
        JOIN
          #{table_name}
        ON
          #{table_name}.id = #{through_table}.#{through_foreign}
        WHERE
          #{table_name}.id = ?
        ORDER BY
          #{source_table}.#{source_primary}
      SQL

      source_options.model_class.parse_all(results)
    end
  end
  
end
