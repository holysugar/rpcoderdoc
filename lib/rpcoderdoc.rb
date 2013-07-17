#require "rpcoderdoc/version"

module Rpcoderdoc
  # Your code goes here...

  class Rpcoder
    attr_accessor :commandlist

    def initialize
      @commandlist = []
    end

    def function(name, &block)
      o = Function.new
      yield o
      @commandlist << [name, o]
    end

    def type(name, &block)
      o = Type.new
      yield o
      @commandlist << [name, o]
    end

    def enum(name, &block)
      o = Enum.new
      yield o
      @commandlist << [name, o]
    end

    def add_template(*); end # NOP
    def export(*); end # NOP

    def method_missing(name, *args)
      $stderr.puts "'#{name}' called"
    end

    class Function
      attr_accessor :params, :return_types, :path, :method, :description
      def initialize
        @params = []
        @return_types = []
      end

      def add_param(*args)
        @params << args
      end

      def add_return_type(*args)
        @return_types << args
      end
    end

    class Type
      attr_accessor :fields, :description
      def initialize
        @fields = []
      end

      def add_field(*args)
        @fields << args
      end
    end

    class Enum
      attr_accessor :constants, :flags, :description
      def initialize
        @constants = []
        @return_types = []
      end

      def add_constant(*args)
        @constants << args
      end
    end
  end

  class Sandbox
    RPCoder = ::Rpcoderdoc::Rpcoder.new

    def require(*); end # NOP

    def eval(script)
      instance_eval(script)

      RPCoder.commandlist
    end
  end

  class TextilePresenter
    def initialize(commandlist)
      @commandlist = commandlist
    end

    def print(io = $stdout)
      io.puts header
      @commandlist.sort.select { |name, object|
        object.is_a? Rpcoder::Function
      }.each do |name, object|
        io.puts textile(name, object)
      end
    end

    private
    def strings_as_table(strings, header = false)
      sep = header ? "|_." : "|"
      sep + strings.join(" #{sep} ") + "|"
    end

    def header
      strings_as_table(%w(Name Path Method Description), true)
    end

    def textile(name, object)
      strings_as_table([name, object.path, object.method, object.description])
    end
  end

  def self.eval(script)
    Sandbox.new.eval(script)
  end
end

