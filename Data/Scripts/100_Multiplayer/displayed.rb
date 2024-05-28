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
      content = DisplayedPlayer.open_file(path)
      #Opening the other players location data
      if content.empty? || content == "UNASSIGNED"
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
        DisplayedPlayer.walkto(75, transferred_data[:direction]) #(Number is temporary)
      else
        $game_variables[296] = transferred_data[:x]
        $game_variables[297] = transferred_data[:y]
        $game_variables[293] = 1 #activate force-tp
        #print("latest location was not set. setting and force-tp.")
        #print("hence, the player location: X- #{$game_variables[298]} Y- #{$game_variables[299]}
        #    last x - #{$game_variables[296]} last y - #{$game_variables[297]}")
        #setting up latest location
      end

  end

  def self.refresh_pos
    player_num = Multiplayer.player_number
    if player_num == 0
      DisplayedPlayer.clean_loc_vars
      return #player numbers were not set -> make the 2nd player in a spot that cannot be seen
    end
    file_path = "client1\\client.rb" if player_num == 2
    file_path = "client2\\client.rb" if player_num == 1
    path = Multiplayer.path(file_path)
    contents = DisplayedPlayer.open_file(path)
    if "#{contents}" == ''
      return
    end

    hash_data = DisplayedPlayer.hash_eval(contents)
    if hash_data[:map_id] == $game_map.map_id
      $game_variables[298] = hash_data[:x]
      $game_variables[299] = hash_data[:y]
    else
      $game_variables[298] = 0
      $game_variables[299] = 0
    end
  end

  def self.open_file(path)
    File.open(path, 'r') do |file|
      contents = file.read
      return contents
    end
  end

  def self.clean_loc_vars
    $game_variables[298] = 0
    $game_variables[299] = 0
    $game_variables[300] = 2
    return
  end
  
  def self.walkto(event_id, direction)
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
    
    #print("Started Walking!")
    #if walk_direction_x >= 5 || walk_direction_x <= -5 || walk_direction_y >= 5 || walk_direction_y <= -5
    if Math.sqrt(walk_direction_x*walk_direction_x+walk_direction_y*walk_direction_y) >= 5
      #if too far: teleport
      #print("player was too far... activating force-tp")
      #print("hence, the player location: X- #{$game_variables[298]} Y- #{$game_variables[299]}
      #      last x - #{$game_variables[296]} last y - #{$game_variables[297]}")
      $game_variables[296] = x
      $game_variables[297] = y
      $game_variables[293] = 1 #set force-tp to true
      return 'teleport'
    end
    if walk_direction_x > 0
      (1..walk_direction_x).each { |i|
        pbMoveRoute($game_map.events[event_id], [
          PBMoveRoute::ChangeSpeed, 4,
          PBMoveRoute::Right,
        ])
        x_steps += 1
      }
    elsif walk_direction_x < 0
      (1..(-1*walk_direction_x)).each { |i|
        pbMoveRoute($game_map.events[event_id], [
          PBMoveRoute::ChangeSpeed, 4,
          PBMoveRoute::Left,
        ])
        x_steps -= 1
      }
    end
    if walk_direction_y < 0
      #print("UP")
      (1..(-1*walk_direction_y)).each { |i|
        pbMoveRoute($game_map.events[event_id], [
          PBMoveRoute::ChangeSpeed, 4,
          PBMoveRoute::Up,
        ])
        y_steps -= 1
      }
    elsif walk_direction_y > 0
      #print("DOWN")
      (1..walk_direction_y).each { |i|
        pbMoveRoute($game_map.events[event_id], [
          PBMoveRoute::ChangeSpeed, 4,
          PBMoveRoute::Down,
        ])
        y_steps += 1
      }
    end
    #print("walk_dir_x: #{walk_direction_x}, walk_dir_y: #{walk_direction_y}")
    #updating locations

    DisplayedPlayer.RotateDirection(event_id, direction)

    $game_variables[298] = (last_x + x_steps)
    $game_variables[299] = (last_y + y_steps)

    $game_variables[296] = x
    $game_variables[297] = y
    return
  end


  def self.RotateDirection(event_id, direction)
    if direction == 2
      pbMoveRoute($game_map.events[event_id], [
        PBMoveRoute::TurnDown,
      ])
    elsif direction == 4
      pbMoveRoute($game_map.events[event_id], [
        PBMoveRoute::TurnLeft,
      ])
    elsif direction == 6
      pbMoveRoute($game_map.events[event_id], [
        PBMoveRoute::TurnRight,
      ])
    elsif direction == 8
      pbMoveRoute($game_map.events[event_id], [
        PBMoveRoute::TurnUp,
      ])
    end
    return
  end

  def self.get_latest_loc
    latest_x = $game_variables[296]
    latest_y = $game_variables[297]
    return true if latest_x != 0 && latest_y != 0
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
    if string == "UNASSIGNED"
      player_num = Multiplayer.player_number
      second_client = "client1" if player_num == 2
      second_client = "client2" if player_num == 1
      return {:x=>0, :y=>0, :direction=>2, :map_id=>0, :player_num=>second_client}
    end

    hash = eval(string)
    #begin
    #  string.sub("{", "").sub("}", "").sub(":","") 
    #  pairs = string[1..-2].split(", ").map { |pair| pair.split("=>").map(&:strip) }
    #  hash = {}
    #  pairs.each { |pair| hash[pair[0][1..-1].to_sym] = pair[1].to_i }
    #  
    #rescue 
    #
    #end
    
    

    #GO BACK TO THIS LATER
    return hash
  end

  def self.moved?(last_loc, curr_loc)
    if last_loc[:x] == curr_loc[:x] && last_loc[:y] == curr_loc[:y] && last_loc[:direction] == curr_loc[:direction] && last_loc[:map_id] == curr_loc[:map_id]
      return false
    else
      return true
    end

  end
  def self.pubsub(event_id)

    if @last_loc_hashed == nil
      return
    end
    #Check if I moved
    curr_loc = Multiplayer.generate_player_data

    if curr_loc.to_s == ''
      return
    end
    #print("[PUBSUB] Comparing #{@last_loc_hashed} And  #{curr_loc}")
    if self.moved?(@last_loc_hashed, curr_loc) == true
      #print("[PUBSUB] You moved!")
      #Saving current location to file
      @last_loc_hashed = curr_loc

      player_num = Multiplayer.player_number
      file_path = "client1\\client.rb" if player_num == 1
      file_path = "client2\\client.rb" if player_num == 2
      if player_num == 0
        return
      end

      apath = Multiplayer.path(file_path)
      File.open(apath, 'w') do |file|
        file.puts curr_loc
        #print("[PUBSUB] Updated location to file.")
      ensure
        file.close
      end
    end


    if @other_last_loc_hashed == nil
      return
    end

    #print("[PUBSUB] Checking for new secondary client movement...")
    #Check if other moved
    file_path = "client1\\client.rb" if @last_loc_hashed[:player_num].to_i == 2
    file_path = "client2\\client.rb" if @last_loc_hashed[:player_num].to_i == 1
    other_curr_loc_hashed = open_file(Multiplayer.path(file_path))

    if other_curr_loc_hashed.to_s == ''
      return
    end

    other_curr_loc_hashed = self.hash_eval(other_curr_loc_hashed)

    #print("[PUBSUB] Comparing #{@other_last_loc_hashed} And  #{other_curr_loc_hashed}")
    if self.moved?(@other_last_loc_hashed, other_curr_loc_hashed)
      #print("[PUBSUB] Second player moved!")

      hashed_loc = other_curr_loc_hashed
      old_hashed_loc = @other_last_loc_hashed

      $game_variables[296] = old_hashed_loc[:x]
      $game_variables[297] = old_hashed_loc[:y]
      $game_variables[300] = hashed_loc[:direction]

      if hashed_loc[:map_id] == $game_map.map_id
        $game_variables[298] = hashed_loc[:x]
        $game_variables[299] = hashed_loc[:y]
      else
        $game_variables[298] = 0
        $game_variables[299] = 0
      end

      self.walkto(event_id, $game_variables[300])
      @other_last_loc_hashed = other_curr_loc_hashed
    end
    #print("[PUBSUB] end of function")
  end

  def self.initializer
    @last_loc_hashed = Multiplayer.generate_player_data

    if @last_loc_hashed[:player_num] == nil
      pbMessage("There was an error getting player number.")
    end
    #print("Last location hashed: #{@last_loc_hashed}")
    File.open(Multiplayer.path("player_num.txt"), 'w') do |file|
      #print("Player num value: #{@last_loc_hashed[:player_num]}")
      file.puts @last_loc_hashed[:player_num]
    ensure
      file.close
    end

    file_path = "client1\\client.rb" if @last_loc_hashed[:player_num] == 2
    file_path = "client2\\client.rb" if @last_loc_hashed[:player_num] == 1
    @other_last_loc_hashed = self.hash_eval(open_file(Multiplayer.path(file_path)))
    #print("Other last loc: #{@other_last_loc_hashed}")
  end

  def self.gui()
    puts "Click Action"
  end

end