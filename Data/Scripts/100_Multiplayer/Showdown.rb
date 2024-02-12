class Showdown
  def self.convert
    path = Multiplayer.path("Team.json")
    File.open(path, 'w') do |file|
      for i in $Trainer.able_party do

        species = i.species

        speciesId = getDexNumberForSpecies(species)
        if speciesId > NB_POKEMON
          bodySpecies = getBodyID(species)
          headSpecies = getHeadID(species)
          bodySpeciesName = GameData::Species.get(bodySpecies).real_name
          headSpeciesName = GameData::Species.get(headSpecies).real_name
          #print("head: #{headSpeciesName} body: #{bodySpeciesName}")
        end


        nickname = i.name

        gender = i.gender #1->M 2->F 3->none

        nature = i.nature_id

        item = i.item_id
        has_item = "#{item}".length < 1 ? false : true

        ability = i.ability_id

        fused = i.fused #nill->""
        #print(fused)


        evs = i.ev #hash of evs
        evs_sorted = "EVs:"
        sum_evs = 0
        evs.each do |ev, val|
          #EVs: 156 HP / 128 Atk / 92 Def / 68 SpA / 64 Spe
          ev_displayed = ""
          ev_displayed = "Def" if "#{ev}".upcase == "DEFENSE"
          ev_displayed = "Atk" if "#{ev}".upcase == "ATTACK"
          ev_displayed = "SpA" if "#{ev}".upcase == "SPECIAL_ATTACK"
          ev_displayed = "SpD" if "#{ev}".upcase == "SPECIAL_DEFENSE"
          ev_displayed = "Spe" if "#{ev}".upcase == "SPEED"
          ev_displayed = "HP" if "#{ev}".upcase == "HP"
          sum_evs = sum_evs+ val.to_i
          #print(sum_evs)
          if sum_evs = 0
            val += 1
          end
          evs_sorted += " #{val} #{ev_displayed} /"
        end

        ivs = i.iv #has of ivs
        ivs_sorted = "IVs:"
        ivs.each do |iv, val|
          #IVs: 156 HP / 128 Atk / 92 Def / 68 SpA / 64 Spe
          iv_displayed = ""
          iv_displayed = "Def" if "#{iv}".upcase == "DEFENSE"
          iv_displayed = "Atk" if "#{iv}".upcase == "ATTACK"
          iv_displayed = "SpA" if "#{iv}".upcase == "SPECIAL_ATTACK"
          iv_displayed = "SpD" if "#{iv}".upcase == "SPECIAL_DEFENSE"
          iv_displayed = "Spe" if "#{iv}".upcase == "SPEED"
          iv_displayed = "HP" if "#{iv}".upcase == "HP"
          ivs_sorted += " #{val} #{iv_displayed} /"
        end

        move1 = i.moves[0].id
        move2 = i.moves[1].id
        move3 = i.moves[2].id
        move4 = i.moves[3].id

        file.puts "#{nickname} (#{headSpeciesName}) (M) @ #{item.downcase}" if has_item != false
        file.puts "#{nickname} (#{headSpeciesName}) (M)" if has_item == false
        file.puts "Ability: #{ability.downcase}"
        file.puts "Fusion: #{bodySpeciesName}"
        file.puts evs_sorted
        file.puts "#{nature.capitalize} Nature"
        file.puts ivs_sorted
        file.puts "- #{move1}".downcase
        file.puts "- #{move2}".downcase
        file.puts "- #{move3}".downcase
        file.puts "- #{move4}".downcase
        file.puts ""
      end
    ensure
      file.close
    end
    #print("Done!")
  end

  def self.npcInterractEvent
    #pbCallBub(2,@event_id)
    pbMessage("Hi!")
    #pbCallBub(2,@event_id)
    pbMessage("I was hired by professor oak to research about pokemon fights!")
    #pbCallBub(2,@event_id)
    pbMessage("I heared there is a place where you can fight players online!")
    #pbCallBub(2,@event_id)
    pbMessage("Do you want to export your team and try it out?")
  end
  def self.npcInterractionConvert
    pbMessage("Exporting Your Team...")
    Showdown.convert
    $game_switches[0700] = true
    pbMessage("Finished Exporting Team!")
    #pbCallBub(2,@event_id)
    pbMessage("Please check your game directory / multiplayer /team.txt ")
    #pbCallBub(2,@event_id)
    pbMessage("Just copy the files contents and import it into play.pokeathlon.com/#teambuilder")
    pbMessage("Copy the sites link?")
  end

  def self.npcInterractCopyLink
    link = 'https://play.pokeathlon.com/#teambuilder'
    IO.popen('clip', 'w') { |pipe|
      pipe.puts link}
    pbMessage("Link copied to clipboard!")
  end


end