Class Multiplayer
    def self.generate_player_data
        data = {}
        data[:x] = game_player.x
        data[:y] = game_player.y
        data[:direct] = $game_player.direction
        data[:map_id] = $game_map.map_id
    end
    def self.initialize
        client_info = {}
        client_info[:game_version] = SETTINGS::GAME_VERSION
        client_info[:game_name] = System.game_title
        client_info[:player_name] = $player.name
    end

