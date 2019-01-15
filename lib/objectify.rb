require 'active_support/inflector'

module Objectify
  def self.included(base)
    base.extend ClassMethods
  end

  class << self
    def register_object name 
      name_string = String(name)
      self.class_eval <<-EOS
        class << self
          def #{name_string.pluralize}
            @@#{name_string.pluralize} ||= []
          end
        end
      EOS
    end
  end

  module ClassMethods
    def object(name, attrs:[])
      klass = Class.new Object
      class_name = String(name).camelize
      name_string = class_name.camelize

      attrs.each do |attr|
        if attr.is_a? Hash
          klass.class_eval <<-EOS
            def #{attr.keys.first.to_s}
              instance_eval #{attr.values.first}
            end
          EOS
        else
          klass.class_eval <<-EOS
            attr_reader :#{attr}
            attr_accessor :#{attr}
          EOS
        end
      end
      
      self.class_eval <<-EOS
        class << self
          def #{name_string}(#{attrs.map{ |a| "#{String(a)}: nil" }.join(', ')})
            item = #{class_name}.new(#{attrs.map{ |a| "#{String(a)}: #{String(a)}" }.join(', ')})
            Objectify.#{name_string.pluralize}.push(item)
            item
          end
        end
      EOS

      self.const_set class_name, klass
      Objectify::register_object name
    end
  end

  class Object
    def initialize(**attrs)
      attrs.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
end