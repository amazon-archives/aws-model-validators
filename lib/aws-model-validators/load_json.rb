module Aws
  module ModelValidators
    module LoadJson

      def load_json(src)
        case src
        when Hash then src
        when Pathname, String then JSON.load(read_file(src))
        else
          msg = "expected a path to a JSON document or hash got: #{src.class}"
          raise ArgumentError, msg
        end
      end

      private

      def read_file(path)
        File.open(path, 'r', encoding: 'UTF-8') { |f| f.read }
      end

    end
  end
end
