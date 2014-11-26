module EntityEvents

  class Interaction < ActiveRecord::Base
    attr_accessible :controller, :action, :parameters, :flag, :actor, :target, :actor_id, :target_id

    belongs_to :actor, polymorphic: true
    belongs_to :target, polymorphic: true

    def self.log( interaction )
      Interaction.create(interaction)
    end

    def params
      YAML::load(parameters)
    end
  end
end