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
