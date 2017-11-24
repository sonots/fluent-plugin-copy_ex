require 'fluent/plugin/out_copy'

module Fluent
  class CopyOutputEx < CopyOutput
    Plugin.register_output('copy_ex', self)

    def initialize
      super
      @ignore_errors = []
    end

    def configure(conf)
      super

      conf.elements.select {|e|
        e.name == 'store'
      }.each.with_index {|e, i|
        @ignore_errors << (e.arg == "ignore_error")
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
          @outputs[idex].emit(tag, _es, NullOutputChain.instance)
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
