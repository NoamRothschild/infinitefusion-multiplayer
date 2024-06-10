module Console
  def self.setup_console
    return unless $DEBUG
    echoln "--------------------------------"
    echoln "#{System.game_title} Output Window"
    echoln "--------------------------------"
    echoln "If you are seeing this window, you are running"
    echoln "#{System.game_title} in Debug Mode. This means"
    echoln "that you're either playing a Debug Version, or"
    echoln "you are playing from within RPG Maker XP."
    echoln ""
    echoln "Closing this window will close the game. If"
    echoln "you want to get rid of this window, run the"
    echoln "program from the Shell, or download a Release"
    echoln "version."
    echoln ""
    echoln "--------------------------------"
    echoln "Debug Output:"
    echoln "--------------------------------"
    echoln ""
  end

  def self.read_input
    gets.strip
  end

  def self.process_input
    loop do
      input = read_input
      unless input.gsub(" ", "").empty?
        STDOUT.sync = true
        puts "\e[A\e[K"
        echo "\e[32mCommand:\e[0m \033[36m#{input}\e[0m\n"
        begin
          eval(input)
        rescue => e
          puts "An error has occurred: #{e}"
        end
      else
        puts "\e[A\e[K"
      end
      STDOUT.sync = false
    end
  end


  def self.start_input_thread
    Thread.new { process_input }
  end
end

module Kernel
  def echo(string)
    return unless $DEBUG
    printf(string.is_a?(String) ? string : string.inspect)
  end

  def echoln(string)
    echo(string)
    echo("\r\n")
  end
end

Console.setup_console
Console.start_input_thread