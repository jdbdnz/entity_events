require 'entity_events/interaction'
require 'entity_events/version'
require 'entity_events/event_finder'
require 'active_support/concern'

module EntityEvents

  extend ActiveSupport::Concern

  included do
    has_many  :interactions, as: :actor
    has_many  :interactions, as: :target
  end

  class << self
    def record(request, current_user, auto_log = true)
      event_finder = EventFinder.find(request.filtered_parameters[:controller])
      entity_event = event_finder.new request, current_user
      entity_event.record if auto_log || entity_event.should_record?
    end
  end

  class EntityEvent
    attr_reader :actor, :action ,:target, :current_user, :target_is_user_defined, :actor_is_user_defined, :request

    def initialize(request, current_user)
      @request = request
      @action = action
      @current_user = current_user
      actor_method = (@action.to_s+'_actor').to_sym
      @actor = if respond_to?(actor_method)
        @actor_is_user_defined = true
        send actor_method
      else
        default_actor
      end

      target_method = (@action.to_s+'_target').to_sym
      @target = if respond_to?(target_method)
        @target_is_user_defined = true
        send target_method
      else
        default_target
      end

    end

    def record
      Interaction.log({  actor:       actor,
                         target:      target,
                         action:      action,
                         controller:  controller,
                         flag:        flag,
                         request_ip:  request.remote_ip
                      })
    end

    def event_class
      self.class.name
    end

    #if auto_log == false, then should_record? will dictate is the action is recorded
    def should_record?
      action_method = (@action.to_s+'?').to_sym
      if respond_to?(action_method)
        #if <action>? is defined follow that
        send action_method
      else
        #else if actor or target is defined, assume we are to record
        actor_is_user_defined || target_is_user_defined
      end
    end

    #You can override methods after this line, however it is not nessisary.
    def controller
      request.filtered_parameters[:controller]
    end

    def action
      request.filtered_parameters[:action]
    end

    def flag
      request.filtered_parameters[:flag]
    end

    def default_actor
      current_user
    end

    def default_target
      id = request.filtered_parameters["#{request.filtered_parameters[:controller].to_s.singularize}_id"] || request.filtered_parameters[:id]
      request.filtered_parameters[:controller].classify.split(':').last.constantize.find id if id
    end


  end

end
