require "confstruct/hash_with_struct_access"

module Confstruct
  
  class Configuration < HashWithStructAccess
  
    def initialize hash=@@hash_class.new, &block
      super({})
      @default_values = hash.is_a?(HashWithStructAccess) ? hash : HashWithStructAccess.new(hash)
      eval_or_yield @default_values, &block
      reset_defaults!
    end
    
    def after_config! obj
    end
    
    def configure *args, &block
      if args[0].respond_to?(:each_pair)
        self.deep_merge!(args[0])
      end
      eval_or_yield self, &block
      after_config! self
      self
    end

    def push! *args, &block
      _stash.push(self.deep_copy)
      configure *args, &block if args.length > 0 or block_given?
      self
    end
    
    def pop!
      if _stash.empty?
        raise IndexError, "Stash is empty"
      else
        obj = _stash.pop
        self.clear
        self.merge! obj
        after_config! self
      end
      self
    end
    
    def reset_defaults!
      self.replace(default_values.deep_copy)
    end

    protected
    def _stash
      @stash ||= []
    end
  end
end