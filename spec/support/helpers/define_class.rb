require 'active_support/core_ext/string/inflections'

module DefineClass
  def define_class(name, parent_class=nil, &block)
    before(:each) do
      Object.send(:remove_const, name) if Object.const_defined?(name)
      
      case parent_class
      when Class
        klass = Class.new(parent_class)
      when String, Symbol
        klass = Class.new(parent_class.to_s.constantize)
      when nil
        klass = Class.new
      end
      
      Object.const_set(name, klass)
    
      klass.class_eval(&block) if block_given?
      klass
    end
  end
end
