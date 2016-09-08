require 'fluent/output'

module Fluent
  class CopyExOutput < MultiOutput
    Plugin.register_output('copy_ex', self)

    config_param :deep_copy, :bool, :default => false

    def initialize
      super
      @outputs = []
      @ignore_errors = []
    end

    attr_reader :outputs, :ignore_errors

    def configure(conf)
      super
      conf.elements.select {|e|
        e.name == 'store'
      }.each {|e|
        type = e['@type'] || e['type']
        unless type
          raise ConfigError, "Missing '@type' parameter on <store> directive"
        end
        log.debug "adding store type=#{type.dump}"

        output = Plugin.new_output(type)
        output.configure(e)
        @outputs << output

        @ignore_errors << (e.arg == "ignore_error")
      }
    end

    def start
      @outputs.each {|o|
        o.start
      }
    end

    def shutdown
      @outputs.each {|o|
        o.shutdown
      }
    end

    def emit(tag, es, chain)
      unless es.repeatable?
        m = MultiEventStream.new
        es.each {|time,record|
          m.add(time, record)
        }
        es = m
      end

      # Here, we do not use OutputChain for custom
      @outputs.each_index do |idx|
        _es = @deep_copy ? es.dup : es
        begin
          @outputs[idx].emit(tag, _es, NullOutputChain.instance)
        rescue => e
          if @ignore_errors[idx]
            log.error :error_class => e.class, :error => e.message
          else
            raise e
          end
        end
      end

      chain.next
    end
  end
end
