class AttrAccessorObject
  def self.my_attr_accessor(*names)

    names.each do |name|
      symbol_name = "@#{name}"
      set = "#{name}="

      define_method(name) { instance_variable_get(symbol_name) }
      define_method(set) { |value| instance_variable_set(symbol_name, value) }

    end
  end
end
