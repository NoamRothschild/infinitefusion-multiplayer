class DisplayedPlayer

  #$game_variables[298] -> 2nd player's X coordinate
  #$game_variables[299] -> 2nd player's Y coordinate
  #$game_variables[300] -> 2nd player's looking direction
  def self.set_location_vars #starts when selecting player 1/2
    player_num = Multiplayer.player_number
    if player_num == 0
      $game_variables[298] = 0
      $game_variables[299] = 0
      return #player numbers were not set -> make the 2nd player in a stop that cannot be seen
    end
    file_path = "client1\\Client.json" if player_num == 2
    file_path = "client2\\Client.json" if player_num == 1
    path = Multiplayer.path(file_path)
    File.open(path, 'r') do |file|
      content = file.read
      if content.empty?
        $game_variables[298] = 0
        $game_variables[299] = 0
        return #will get out of here if 2nd player is
      end
      transferred_data = DisplayedPlayer.hash_eval(content)
      if transferred_data[:map_id] == $game_map.map_id #if both players are on the same map
        $game_variables[298] = transferred_data[:x]
        $game_variables[299] = transferred_data[:y]
        $game_variables[300] = transferred_data[:direction]
      end
    end
  end

  def self.clean_data
    path = Multiplayer.path("client1\\Client.json")
    File.open(path, 'w') do |file|
      file.write("")
    end
    path = Multiplayer.path("client2\\Client.json")
    File.open(path, 'w') do |file|
      file.write("")
    end
  end

  def self.hash_eval(string)
    #{:x=>31, :y=>10, :direction=>6, :map_id=>77, :player_num=>1}
    string.sub("{", "").sub("}", "").sub(":","")
    pairs = string[1..-2].split(", ").map { |pair| pair.split("=>").map(&:strip) }
    hash = {}
    pairs.each { |pair| hash[pair[0][1..-1].to_sym] = pair[1].to_i }
    return hash
  end
end