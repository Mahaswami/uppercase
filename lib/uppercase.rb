ActiveRecord::Base.class_eval do

  class_inheritable_accessor :uppercase_columns

  self.uppercase_columns = []

  class << self
    def set_primary_keys_with_uppercase(*keys)
      set_primary_keys_without_uppercase(*keys)
      store_in_uppercase(*keys)
    end
    alias_method_chain :set_primary_keys, :uppercase
  end
  
  def self.store_in_uppercase(*columns)
    self.uppercase_columns += columns
    self.uppercase_columns.uniq!
    columns.each {|c| create_setter_method_for_column(c)}
  end

  def self.create_setter_method_for_column(column)
    if self.instance_methods.include?("#{column}=")
      define_method "#{column}_with_uppercase=" do |value|
        send("#{column}_without_uppercase=", value.to_upper)
      end
      alias_method_chain "#{column}=", :uppercase
    else
      define_method "#{column}=" do |value|
        if self.class.columns_hash.keys.include?(column.to_s)
          self["#{column}".to_sym] = value.to_upper
        else
          instance_variable_set("@#{column}", value.to_upper)
        end
      end
    end
  end

  def self.store_in_uppercase?(column)
    self.uppercase_columns.include?(column.to_sym)
  end

end

class Object
  def to_upper
    self.kind_of?(String) ? self.upcase : self
  end
end