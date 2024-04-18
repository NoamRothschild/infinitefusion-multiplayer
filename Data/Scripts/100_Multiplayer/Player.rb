
class Multiplayer

    def self.path(file_name)
        script_path = File.expand_path(__FILE__)
        game_folder = File.expand_path(File.join(script_path, '..'))
        multiplayer_folder = File.join(game_folder, 'multiplayer', file_name)
        return multiplayer_folder
    end
    def self.generate_player_data
        player_num = Multiplayer.player_number
        if player_num == 0
            return nil
        end
        data = {}
        data[:x] = $game_player.x
        data[:y] = $game_player.y
        data[:direction] = $game_player.direction
        data[:map_id] = $game_map.map_id
        data[:player_num] = player_num
        file_name = "client1\\client.rb" if player_num == 1
        file_name = "client2\\client.rb" if player_num == 2
        path = Multiplayer.path(file_name)
        File.open(path, 'w') do |file|
            file.puts data
        ensure
        file.close
        end
        return data
    end
    def self.initialize
        client_info = {}
        client_info[:game_version] = SETTINGS::GAME_VERSION
        client_info[:game_name] = System.game_title
        client_info[:player_name] = $player.name
    end

    def self.player_number
        p1 = $game_variables[294]
        p2 = $game_variables[295]
        return 1 if p1 == 1 && p2 == 0
        return 2 if p1 == 0 && p2 == 1
        return 0 #only get here if multiplayer is not activated or cleaned
    end
end

