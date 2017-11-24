require 'fluent/plugin/out_copy'

module Fluent
  class CopyExOutput < CopyOutput
    Plugin.register_output('copy_ex', self)

    attr_reader :ignore_errors

    def initialize
      super
      @ignore_errors = []
    end

    def configure(conf)
      super

      conf.elements.select {|e|
        e.name == 'store'
      }.each {|e|
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
      outputs.each.with_index do |output, idx|
        begin
          output.emit(tag, @deep_copy ? es.dup : es, NullOutputChain.instance)
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
