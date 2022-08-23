---------- settings ----------
local playlist_path = "/tmp/mpv-playlist"
local result_path = "/tmp/mpv-fzf-result"
local search_key = ";"
local terminal = "konsole -e"
---------- end ---------------

local function get_name(play_index)
  local name_title = mp.get_property("playlist/" .. play_index .. "/title")
  if name_title ~= nil then
    return name_title
  else
    return mp.get_property("playlist/" .. play_index .. "/filename")
  end
end

local function export_playlist()
  local playlist = io.open(playlist_path, "w")
  if playlist ~= nil then
    for play_index = 0, mp.get_property_number("playlist-count", 0) - 1 do
      playlist:write(string.format(
        "%d|%s\n", play_index, get_name(play_index)
      ))
    end
    playlist:close()
  end
end

local function fzf_in_term()
  os.execute(string.format(
    "%s sh -c 'cat %s | fzf > %s'", terminal, playlist_path, result_path
  ))
  local f = io.open(result_path)
  if f ~= nil then
    local t = f:read()
    f:close()
    return t
  else
    return nil
  end
end

local function fzf_playlist()
  export_playlist()
  local search_result = fzf_in_term()
  if search_result ~= nil then
    local play_index = string.match(search_result, "^(%d+)|")
    mp.command("playlist-play-index " .. play_index)
  end
end

mp.add_key_binding(search_key, "fzf-playlist", fzf_playlist)
