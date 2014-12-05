module EntityEvents

  class Interaction < ActiveRecord::Base
    attr_accessible :controller, :action, :parameters, :flag, :actor, :target, :actor_id, :target_id, :request_ip

    belongs_to :actor, polymorphic: true
    belongs_to :target, polymorphic: true

    def self.log( interaction )
      Interaction.create(interaction)
    end

  end
end