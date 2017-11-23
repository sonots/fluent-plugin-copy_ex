require 'fluent/plugin/multi_output'
require 'fluent/config/error'
require 'fluent/event'

module Fluent::Plugin
  class CopyExOutput < MultiOutput
    Fluent::Plugin.register_output('copy_ex', self)

    desc 'If true, pass different record to each `store` plugin.'
    config_param :deep_copy, :bool, default: false

    def initialize
      super
      @ignore_errors = []
    end

    attr_reader :ignore_errors

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

      outputs.each_with_index do |output, idx|
        _es = @deep_copy ? es.dup : es
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
