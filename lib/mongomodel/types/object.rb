module MongoModel
  module Types
    class Object
      def cast(value)
        value
      end
      
      def to_mongo(value)
        value
      end
      
      def from_mongo(value)
        value
      end
    end
  end
end
