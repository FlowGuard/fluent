require 'fluent/plugin/filter'

module Fluent::Plugin
  class ExpandTTLFilter < Fluent::Plugin::Filter
    # Register this filter as "passthru"
    Fluent::Plugin.register_filter('expand_ttl', self)

    # config_param works like other plugins
    desc "TTL map key"
    config_param :ttl_map_key, :string, default: 'inTTL'

    desc "TTL key"
    config_param :ttl_key, :string, default: 'ttl'

    desc "TTL distance"
    config_param :ttl_value, :string, default: 'distance'

    desc "Value field"
    config_param :value_field, :string, default: 'count'

    def configure(conf)
      super
      # do the usual configuration here
    end

    def ttl_distance(ttl)
      if ttl > 128
        return 255 - ttl
      elsif ttl > 64
        return 128 - ttl
      else
        return 64 - ttl
      end
    end

    def expand(tag, time, record, es)
      if record.key?("type") and record["type"].end_with?("TTL_SUM")
        if record.key?(@ttl_map_key)
          record[@ttl_map_key].each { |key, value|
            new_record = record.clone
            new_record[@ttl_key] = key
            new_record[@ttl_value] = ttl_distance(key.to_i)
            new_record[@value_field] = value
            new_record.delete(@ttl_map_key)
            es.add(time, new_record)
          }
        end
      else
        es.add(time, record)
      end
    end

    def filter_stream(tag, es)
      new_es = Fluent::MultiEventStream.new
        es.each { |time, record|
          begin
            expand(tag, time, record, new_es)
          rescue => e
            router.emit_error_event(tag, time, record, e)
          end
        }
        new_es
    end
  end
end
