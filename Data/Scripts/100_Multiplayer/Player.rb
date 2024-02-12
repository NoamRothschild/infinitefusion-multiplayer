Class Multiplayer
    def self.path(file_name)
        script_path = File.expand_path(__FILE__)
        game_folder = File.expand_path(File.join(script_path, '..'))
        return = File.join(game_folder, 'multiplayer', file_name)
    end
    def self.generate_player_data
        data = {}
        data[:x] = game_player.x
        data[:y] = game_player.y
        data[:direct] = $game_player.direction
        data[:map_id] = $game_map.map_id
        path = Multiplayer.path("Client.json")
        File.open(path 'w') do |file|
            file.puts data
        ensure
        file.close
        end
    end
    def self.initialize
        client_info = {}
        client_info[:game_version] = SETTINGS::GAME_VERSION
        client_info[:game_name] = System.game_title
        client_info[:player_name] = $player.name
    end
end


