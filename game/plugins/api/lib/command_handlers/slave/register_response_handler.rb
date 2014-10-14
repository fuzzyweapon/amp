module AresMUSH
  module Api
    class SlaveRegisterResponseHandler < ApiResponseHandler
      attr_accessor :args
      
      def crack!
        self.args = ApiRegisterResponseArgs.create_from(response.args_str)
      end
      
      def validate
        args.validate
      end
      
      def handle
        game = Game.master
        game.api_game_id = args.game_id
        game.save

        central = Api.get_destination(ServerInfo.arescentral_game_id)
        if (central.nil?)
          raise "Can't find AresCentral server info."
        end
        central.key = args.api_key
        central.save
        
        Global.logger.info "API info updated."
      end
    end
  end
end