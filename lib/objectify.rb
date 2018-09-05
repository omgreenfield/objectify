require 'active_support/inflector'

module Objectify
  def self.included(base)
    base.extend ClassMethods
  end

  class << self
    def register_object name 
      nameString = String(name)
      self.class_eval <<-EOS
        class << self
          def #{nameString.pluralize}
            @@#{nameString.pluralize} ||= []
          end
        end
      EOS
    end
  end

  module ClassMethods
    def object(name, attrs:[])
      klass = Class.new Object
      className = String(name).camelize
      nameString = String(name)

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
          def #{nameString}(#{attrs.map{ |a| "#{String(a)}: nil" }.join(', ')})
            item = #{className}.new(#{attrs.map{ |a| "#{String(a)}: #{String(a)}" }.join(', ')})
            Objectify.#{nameString.pluralize}.push(item)
            item
          end
        end
      EOS

      self.const_set className, klass
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