def test_http_get
  url = "http://localhost:8080"
  response = HTTPLite.get(url)
  if response[:status] == 200
    p response[:body]
  end
end

def updateCreditsFile
  return if $PokemonSystem.download_sprites != 0
  download_file(Settings::CREDITS_FILE_URL,Settings::CREDITS_FILE_PATH,)
end

def download_file(url, saveLocation)
  begin
    response = HTTPLite.get(url)
    p response
    if response[:status] == 200
      File.open(saveLocation, "wb") do |file|
        file.write(response[:body])
      end
      echo _INTL("\nDownloaded file {1} to {2}", url, saveLocation)
      return saveLocation
    end
    return nil
  rescue MKXPError => error
    echo error
    return nil
  end
end

def download_sprite(base_path, head_id, body_id, saveLocation = "Graphics/temp")
  begin
    downloaded_file_name = _INTL("{1}/{2}.{3}.png", saveLocation, head_id, body_id)
    return downloaded_file_name if pbResolveBitmap(downloaded_file_name)
    url = _INTL(base_path, head_id, body_id)
    response = HTTPLite.get(url)
    if response[:status] == 200
      File.open(downloaded_file_name, "wb") do |file|
        file.write(response[:body])
      end
      echo _INTL("\nDownloaded file {1} to {2}", downloaded_file_name, saveLocation)
      return downloaded_file_name
    end
    return nil
  rescue MKXPError
    return nil
  end
end

def download_autogen_sprite(head_id, body_id)
  return nil if $PokemonSystem.download_sprites != 0
  url = "https://raw.githubusercontent.com/Aegide/autogen-fusion-sprites/master/Battlers/{1}/{1}.{2}.png"
  destPath = _INTL("{1}{2}", Settings::BATTLERS_FOLDER, head_id)
  sprite = download_sprite(_INTL(url, head_id, body_id), head_id, body_id, destPath)
  return sprite if sprite
  return nil
end

def download_custom_sprite(head_id, body_id)
  return nil if $PokemonSystem.download_sprites != 0
  #base_path = "https://raw.githubusercontent.com/Aegide/custom-fusion-sprites/main/CustomBattlers/{1}.{2}.png"
  url = "https://raw.githubusercontent.com/infinitefusion/sprites/main/CustomBattlers/{1}.{2}.png"
  destPath = _INTL("{1}{2}", Settings::CUSTOM_BATTLERS_FOLDER_INDEXED, head_id)
  sprite = download_sprite(_INTL(url, head_id, body_id), head_id, body_id, destPath)
  return sprite if sprite
  return nil
end

#format: [1.1.png, 1.2.png, etc.]
# https://api.github.com/repos/infinitefusion/contents/sprites/CustomBattlers
#   repo = "Aegide/custom-fusion-sprites"
#   folder = "CustomBattlers"
#
# todo: github api returns a maximum of 1000 files. Need to find workaround.
# Possibly using git trees https://docs.github.com/fr/rest/git/trees?apiVersion=2022-11-28#get-a-tree
def list_online_custom_sprites
  return nil
  #   repo = "infinitefusion/sprites"
  #   folder = "CustomBattlers"
  # api_url = "https://api.github.com/repos/#{repo}/contents/#{folder}"
  # response = HTTPLite.get(api_url)
  # return HTTPLite::JSON.parse(response[:body]).map { |file| file['name'] }
end

GAME_VERSION_FORMAT_REGEX = /\A\d+(\.\d+)*\z/
def fetch_latest_game_version
  begin
    download_file(Settings::VERSION_FILE_URL,Settings::VERSION_FILE_PATH,)
    version_file = File.open(Settings::VERSION_FILE_PATH, "r")
    version = version_file.first
    version_file.close

    version_format_valid = version.match(GAME_VERSION_FORMAT_REGEX)

    return version if version_format_valid
    return nil
  rescue MKXPError, Errno::ENOENT => error
    echo error
    return nil
  end

end
