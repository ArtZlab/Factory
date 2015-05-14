require "factorygem/version"

module Factorygem
  class Factory
    def self.new(*args, &block)
      raise ArgumentError if args.empty?
     
      object = Class.new do 
        Object.const_set(args.shift, self) if args.first.is_a? String
        self.class_eval(&block) if block_given?
        args.each do |a| 
          define_method ("#{a}")  {instance_variable_get "@#{a}"}
          define_method ("#{a}=") {|var| instance_variable_set("@#{a}", var)}
        end
  
        define_method :initialize do |*vars|
          args.each{|a| instance_variable_set("@#{a}", vars[args.index(a)])}
        end
  
        define_method :[] do |*vars|
          vars.map!{|v|
            if v.is_a? Integer
              raise ArgumentError if  v > self.instance_variables.length - 1
              key = self.instance_variables[v].to_s.delete("@") 
              v = self.send(key)
            else
              raise ArgumentError if self.instance_variables.find{|var| var == "@#{v.to_s}".to_sym}.nil?
              v = self.send("#{v}")
            end
            }
        end
      end
    end
  end
end
