
local moremoves = {
	double_jump = {},
	crawling = {},
	rolling = {},
	shift_dtap = {},
}


player_api.register_model("moremoves_character.b3d", {
	animation_speed = 30,
	textures = {"character.png"},
	animations = {
		-- Standard animations.
		stand_     = {x = 0,   y = 79},
		lay_       = {x = 162, y = 166},
		walk_      = {x = 168, y = 187},
		mine_      = {x = 189, y = 198},
		walk_mine_ = {x = 200, y = 219},
		sit_       = {x = 81,  y = 160},
		roll       = {x = 221,  y = 241},
		crawl       = {x = 242,  y = 251},
		crawl_lay       = {x = 252,  y = 252},
		bumming       = {x = 254,  y = 254},
	},
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
	stepheight = 0.6,
	eye_height = 1.5,
})


minetest.register_on_joinplayer(function(player)
	player_api.set_model(player, "moremoves_character.b3d")
	player:set_local_animation({x = 0,   y = 0}, {x = 0,   y = 0}, {x = 0,   y = 0}, {x = 0,   y = 0}, 30)
end)


local rollingtick = false
local timer = 10

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	for _,player in pairs(minetest.get_connected_players()) do
    local pos = player:get_pos()
    local controls = player:get_player_control()
		local vel = player:get_velocity()
		local dir = player:get_look_dir()
    if moremoves.double_jump[player] ~= true and minetest.get_node({x=pos.x, y=pos.y - .5, z=pos.z}).name ~= "air" then
      moremoves.double_jump[player] = true
    end

    if (not controls.sneak or not controls.aux1) and moremoves.crawling[player] == true then
      moremoves.crawling[player] = false
    end

		if controls.aux1 and controls.sneak and moremoves.rolling[player] == false then
	    moremoves.crawling[player] = true
	  end

    if moremoves.crawling[player] == true then
      player:set_properties({eye_height = 0.5})
    elseif moremoves.rolling[player] == true then
      player:set_properties({eye_height = 0.5})
    else
			player:set_properties({eye_height = 1.5})
		end


		if moremoves.rolling[player] == true and rollingtick == false then
			rollingtick = true
			minetest.after(1, function()
				moremoves.rolling[player] = false
			end)
		end

		if moremoves.rolling[player] == false and rollingtick == true then
			rollingtick = false
		end

		if moremoves.rolling[player] == true then
			if math.abs(vel.z) < 7 and math.abs(vel.x) < 7 then
				player:add_velocity({x=dir.x * 2, y=0, z=dir.z * 2})
			end
		end

  end
end)


controls.register_on_press(function(player, key)
  if key~="jump" then return end
  local pos = player:get_pos()
  local vel = player:get_velocity()
  if vel.y < 1.4 and moremoves.double_jump[player] == true and minetest.get_node({x=pos.x, y=pos.y - .5, z=pos.z}).name == "air" then
    moremoves.double_jump[player] = false
    player:add_velocity({x=0,y=vel.y * -1 + 7.5,z=0})
    minetest.sound_play("jump", {
  		pos = pos,
  		gain = 1.0,
  		max_hear_distance = 8,
  	}, true)
  end
end)



controls.register_on_release(function(player, key)
	if key~="sneak" then return end
	moremoves.shift_dtap[player] = true
	minetest.after(.2, function()
		moremoves.shift_dtap[player] = false
	end)
end)


controls.register_on_press(function(player, key)
	if key~="sneak" then return end
	if moremoves.shift_dtap[player] == true then
		if moremoves.rolling[player] ~= true then
			moremoves.rolling[player] = true
		end
	end
end)


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
			player_set_animation(player, "roll", animation_speed_mod * 2)
		elseif moremoves.crawling[player] ~= true and moremoves.double_jump[player] == false then
			player_set_animation(player, "bumming", animation_speed_mod * 2)
		elseif controls.up or controls.down or controls.left or controls.right then
			if moremoves.crawling[player] == true then
				player_set_animation(player, "crawl", animation_speed_mod)
			elseif controls.LMB or controls.RMB then
				player_set_animation(player, "walk_mine_", animation_speed_mod)
			else
				player_set_animation(player, "walk_", animation_speed_mod)
			end
		elseif moremoves.crawling[player] == true then
			player_set_animation(player, "crawl_lay", animation_speed_mod)
		elseif controls.LMB or controls.RMB then
			player_set_animation(player, "mine_", animation_speed_mod)
		else
			player_set_animation(player, "stand_", animation_speed_mod)
		end
	end
end)
