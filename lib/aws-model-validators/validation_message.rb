module Aws
  module ModelValidators
    class ValidationMessage < String

      def initialize(path, message)
        super("#{path} #{message}")
      end

      # @return [String]
      attr_reader :path

      # @return [String]
      attr_reader :message

    end
  end
end
