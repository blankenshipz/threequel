module Threequel
  module Commandant
    module Logging
      # extend ActiveSupport::Concern

      def self.extended(base)
        base.class.instance_eval do
          extend ActiveModel::Callbacks
          define_model_callbacks :execute
          around_execute :log
        end
      end

      def log
        Threequel::Logger.new(:print_output => true).log(@name, attributes) do
          yield
        end
      end

      def execute_on(connection)
        run_callbacks :execute do
          super
        end
      end

    end
  end
end