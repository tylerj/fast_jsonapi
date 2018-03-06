require 'active_support/core_ext/object'
require 'active_support/concern'
require 'active_support/inflector'
require 'oj'
require 'multi_json'
require 'fast_jsonapi/serialization_core'

module FastJsonapi
  module ObjectSerializer
    extend ActiveSupport::Concern
    include SerializationCore

    def initialize(resource)
      # @records if enumerables like Array, ActiveRecord::Relation but if Struct just make it a @record
      if resource.respond_to?(:each) && !resource.respond_to?(:each_pair)
        @records = resource
      else
        @record = resource
      end
    end

    def serializable_hash
      return hash_for_one_record if @record
      return hash_for_multiple_records if @records
    end

    def hash_for_one_record
      self.class.record_hash(@record)
    end

    def hash_for_multiple_records
      @records.map do |record|
        self.class.record_hash(record)
      end
    end

    def serialized_json
      self.class.to_json(serializable_hash)
    end

    class_methods do
      def use_hyphen
        @hyphenated = true
      end

      def attributes(*attributes_list)
        attributes_list = attributes_list.first if attributes_list.first.class.is_a?(Array)
        self.attributes_to_serialize = {} if self.attributes_to_serialize.nil?
        attributes_list.each do |attr_name|
          method_name = attr_name
          key = method_name
          if @hyphenated
            key = attr_name.to_s.dasherize.to_sym
          end
          attributes_to_serialize[key] = method_name
        end
      end

      def compute_serializer_name(serializer_key)
        namespace = self.name.gsub(/()?\w+Serializer$/, '')
        serializer_name = serializer_key.to_s.classify + 'Serializer'
        return (namespace + serializer_name).to_sym if namespace.present?
        (serializer_key.to_s.classify + 'Serializer').to_sym
      end
    end
  end
end
