require 'fluent/plugin/out_copy'

module Fluent::Plugin
  class CopyOutputEx < CopyOutput
    Fluent::Plugin.register_output('copy_ex', self)

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

    def process(tag, es)
      unless es.repeatable?
        m = Fluent::MultiEventStream.new
        es.each {|time,record|
          m.add(time, record)
        }
        es = m
      end

      outputs.each.with_index do |output, idx|
        begin
          output.emit_events(tag, @deep_copy ? es.dup : es)
        rescue => e
          if @ignore_errors[idx]
            log.error :error_class => e.class, :error => e.message
          else
            raise e
          end
        end
      end
    end
  end
end
