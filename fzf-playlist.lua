---------- settings ----------
local playlist_path = "/tmp/mpv-playlist"
local result_path = "/tmp/mpv-fzf-result"
local search_key = ";"
local terminal = "st"
---------- end ---------------

local function export_playlist()
	local playlist = io.open(playlist_path, "w")
	for play_index = 0, mp.get_property_number("playlist-count", 0) - 1 do
		playlist:write(string.format(
            "%d|%s\n", play_index, mp.get_property("playlist/" .. play_index .. "/title")
        ))
	end
	playlist:close()
end

local function fzf_in_term()
	os.execute(string.format(
        "%s sh -c 'cat %s | fzf > %s'", terminal, playlist_path, result_path
    ))
    local f = io.open(result_path)
    local t = f:read()
    f:close()
    return t
end

local function fzf_playlist()
	export_playlist()
    local search_result = fzf_in_term()
	local play_index = string.match(search_result, "^(%d+)|")
	mp.command("playlist-play-index " .. play_index)
end

mp.add_key_binding(search_key, "fzf-playlist", fzf_playlist)
