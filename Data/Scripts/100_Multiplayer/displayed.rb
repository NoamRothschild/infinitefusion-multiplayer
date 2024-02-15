class DisplayedPlayer
  #$game_variables[296] -> force-tp [true->1 / false->0]
  #$game_variables[296] -> 2nd player's last X coordinate
  #$game_variables[297] -> 2nd player's last Y coordinate
  #$game_variables[298] -> 2nd player's X coordinate
  #$game_variables[299] -> 2nd player's Y coordinate
  #$game_variables[300] -> 2nd player's looking direction
  def self.set_location_vars #starts when selecting player 1/2
    $game_variables[293] = 0
    player_num = Multiplayer.player_number
    if player_num == 0
      DisplayedPlayer.clean_loc_vars
      return #player numbers were not set -> make the 2nd player in a spot that cannot be seen
    end
    file_path = "client1\\client.rb" if player_num == 2
    file_path = "client2\\client.rb" if player_num == 1
    path = Multiplayer.path(file_path)
    File.open(path, 'r') do |file|
      #Opening the other players location data
      content = file.read
      if content.empty?
        DisplayedPlayer.clean_loc_vars
        return #will get out of here if 2nd player is not yet registered
      end
      transferred_data = DisplayedPlayer.hash_eval(content) #Custom function to open ruby hashes that is safer that eval()
      if transferred_data[:map_id] != $game_map.map_id #if both players are not on the same map
        DisplayedPlayer.clean_loc_vars
        return
        elsif transferred_data[:map_id] == $game_map.map_id #if both players are on the same map
          $game_variables[298] = transferred_data[:x]
          $game_variables[299] = transferred_data[:y]
          $game_variables[300] = transferred_data[:direction]
      end

      if DisplayedPlayer.get_latest_loc
        #Move 1 tile towards updated location if player has a last location saved
        DisplayedPlayer.walkto(75) #(Number is temporary)
      else
        $game_variables[296] = transferred_data[:x]
        $game_variables[297] = transferred_data[:y]
        $game_variables[293] = 1 #activate force-tp
        print("latest location was not set. setting and force-tp.")
        print("hence, the player location: X- #{$game_variables[298]} Y- #{$game_variables[299]}
            last x - #{$game_variables[296]} last y - #{$game_variables[297]}")
        #setting up latest location
      end

    end
  end

  def self.clean_loc_vars
    $game_variables[298] = 0
    $game_variables[299] = 0
    $game_variables[300] = 2
    return
  end
  def self.walkto(event_id)
    x = $game_variables[298]
    y = $game_variables[299]
    last_x = $game_variables[296]
    last_y = $game_variables[297]
    walk_direction_x = x-last_x
    walk_direction_y = y-last_y
    x_steps = 0
    y_steps = 0
    if walk_direction_x == 0 && walk_direction_y == 0
      return #dont move
    end
    if walk_direction_x >= 5 || walk_direction_x <= -5 || walk_direction_y >= 5 || walk_direction_y <= -5
      #if too far: teleport
      print("player was too far... activating force-tp")
      print("hence, the player location: X- #{$game_variables[298]} Y- #{$game_variables[299]}
            last x - #{$game_variables[296]} last y - #{$game_variables[297]}")
      $game_variables[296] = x
      $game_variables[297] = y
      $game_variables[293] = 1 #set force-tp to true
      return 'teleport'
    elsif walk_direction_x > 0
      pbMoveRoute($game_map.events[event_id], [
        PBMoveRoute::ChangeSpeed, 4,
        PBMoveRoute::Right,
      ])
      x_steps += 1
    elsif walk_direction_x < 0
      pbMoveRoute($game_map.events[event_id], [
        PBMoveRoute::ChangeSpeed, 4,
        PBMoveRoute::Left,
      ])
      x_steps -= 1
    elsif walk_direction_y < 0
      pbMoveRoute($game_map.events[event_id], [
        PBMoveRoute::ChangeSpeed, 4,
        PBMoveRoute::Up,
      ])
      y_steps -= 1
    elsif walk_direction_y > 0
      pbMoveRoute($game_map.events[event_id], [
        PBMoveRoute::ChangeSpeed, 4,
        PBMoveRoute::Down,
      ])
      y_steps += 1
    end
    #updating locations
    $game_variables[296] = x
    $game_variables[297] = y
    $game_variables[298] = (x + x_steps)
    $game_variables[299] = (y + y_steps)
    return
  end
  def self.get_latest_loc
    latest_x = $game_variables[296]
    latest_y = $game_variables[297]
    return true if latest_x != nil && latest_y != nil
    return false
  end

  def self.clean_data
    path = Multiplayer.path("client1\\client.rb")
    File.open(path, 'w') do |file|
      file.write("")
    end
    path = Multiplayer.path("client2\\client.rb")
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