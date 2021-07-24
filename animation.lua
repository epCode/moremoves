-- Minetest 0.4 mod: player
-- See README.txt for licensing and other information.


-- Player animation blending
-- Note: This is currently broken due to a bug in Irrlicht, leave at 0

-- Check each player and apply animations
local player_set_animation = player_api.set_animation
minetest.register_globalstep(function()
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local controls = player:get_player_control()
		local animation_speed_mod = 30

		-- Determine if the player is sneaking, and reduce animation speed if so
		if controls.sneak then
			animation_speed_mod = animation_speed_mod / 2
		end

		-- Apply animations based on what the player is doing
		if player:get_hp() == 0 then
			player_set_animation(player, "lay_")
		-- Determine if the player is walking
    elseif moremoves.rolling[player] == true then
      player_set_animation(player, "roll", animation_speed_mod)
		elseif controls.up or controls.down or controls.left or controls.right then
			if controls.LMB or controls.RMB then
				player_set_animation(player, "walk_mine_", animation_speed_mod)
			else
				player_set_animation(player, "walk_", animation_speed_mod)
			end
		elseif controls.LMB or controls.RMB then
			player_set_animation(player, "mine_", animation_speed_mod)
		else
			player_set_animation(player, "stand_", animation_speed_mod)
		end
	end
end)
