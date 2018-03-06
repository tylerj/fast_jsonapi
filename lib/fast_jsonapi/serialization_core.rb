require 'active_support/concern'

module FastJsonapi
  module SerializationCore
    extend ActiveSupport::Concern

    included do
      class << self
        attr_accessor :attributes_to_serialize
      end
    end

    class_methods do
      def attributes_hash(record)
        attributes_hash = {}
        attributes_to_serialize.each do |key, method_name|
          attributes_hash[key] = record.send(method_name)
        end
        attributes_hash
      end

      def record_hash(record)
        attributes_hash(record)
      end

      def to_json(payload)
        MultiJson.dump(payload) if payload.present?
      end
    end
  end
end
