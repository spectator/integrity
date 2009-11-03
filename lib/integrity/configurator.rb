module Integrity
  class Configurator
    attr_accessor :builder, :logger, :base_uri,
      :user, :pass, :hash_pass, :build_all

    def initialize
      yield(self)
    end

    def database=(uri)
      DataMapper.setup(:default, uri)
    end

    def directory=(dir)
      Bob.directory = dir
    end

    def directory
      Bob.directory
    end

    def base_uri=(uri)
      @base_uri = Addressable::URI.parse(uri)
    end

    def builder(*args)
      @builder ||= begin
        klass = builder_class(args.first)
        case args.size
        when 1 then klass
        when 2 then klass.tap { |b| b.setup(args.last) }
        else
          raise ArgumentError
        end
      end
    end

    def push(*args)
      @push ||= Array(args)
    end

    def log=(log)
      @logger = Logger.new(log)
      Bob.logger = @logger
    end

    def protect?
      user && pass
    end

    def hash_pass?
      !! hash_pass
    end

    def build_all?
      !! build_all
    end

    private
      def builder_class(name)
        case name
        when :threaded then Integrity::ThreadedBuilder
        when :dj
          require "integrity/dj"
          Integrity::DelayedBuilder
        else
          fail "Unknown builder #{name}"
        end
      end
  end
end
