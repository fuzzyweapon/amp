module AresMUSH
  module Tinker
    class TinkerCmd
      include CommandHandler
      include CommandWithoutSwitches
      include CommandRequiresLogin
            
      def crack!
      end
      
      def check_can_manage
        return t('dispatcher.not_allowed') if !enactor.can_manage_game?
        return nil
      end
      
      def handle
        g = Game.master
        g.api_game_id = nil
        g.api_key = nil
        g.save
        # Put whatever you need to do here.
        client.emit_success "Done!"
      end

    end
  end
end
