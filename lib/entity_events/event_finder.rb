module EntityEvents
  class EventFinder
    
    class << self 
      
      def find(hint)
        #get the entity's custom EntityEvent
        begin
          entity = from_hint(hint)
          entity = entity.constantize
        rescue NameError
          #if not found then use the default EntityEvent
          EntityEvents::EntityEvent
        end
      end


      private

        def from_hint(hint)
          if hint.respond_to?(:event_class)
            hint.event_class
          elsif hint.class.respond_to?(:event_class)
            hint.class.event_class
          else
            entity = if hint.respond_to?(:model_name)
              hint.model_name
            elsif hint.class.respond_to?(:model_name)
              hint.class.model_name
            elsif hint.is_a?(Class)
              hint
            elsif hint.is_a?(Symbol)
              hint.to_s.classify
            elsif hint.is_a?(String)
              hint.classify
            else
              hint.class
            end
            "#{entity}Event"
          end
        end

    end
    
  end
end