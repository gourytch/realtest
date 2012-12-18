--description; name; reproduction: texture; number_of_flowers, interval, chance, radius; death: interval, chance; light; grounds;
local flowers = {
	{"Camomile", "camomile", "flowers_camomile.png", 2, 1, 1, 5, 5, 10, 8, {"default:dirt", "default:dirt_with_grass", "default:dirt_with_clay", "default:dirt_with_grass_and_clay"}}
}

for i, flower in ipairs(flowers) do
	minetest.register_node("flowers:"..flower[2], {
		description = flower[1],
		drawtype = "plantlike",
		tiles = {flower[3]},
		inventory_image = flower[3],
		wield_image = flower[3],
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		groups = {dig_immediate=3},
		selection_box = {
			type = "fixed",
			fixed = {-0.2, -0.5, -0.2, 0.2, 0.2, 0.2}
		}
	})
	
	local function grow_flower(pos)
		if minetest.env:get_node(pos).name ~= "air" then
			return
		end
		if not minetest.env:get_node_light(pos) then
			return
		end
		if minetest.env:get_node_light(pos) < flower[10] then
			return
		end
		if table.contains(flower[11], minetest.env:get_node({x=pos.x,y=pos.y-1,z=pos.z}).name) then
			minetest.env:add_node(pos, {name = "flowers:"..flower[2]})
		end
	end
	
	minetest.register_abm({
		interval = flower[5],
		chance = flower[6],
		nodenames = {"flowers:"..flower[2]},
		action = function(pos, node, active_object_count, active_object_count_wider)
			if minetest.env:find_node_near(pos, flower[7], node.name) then
				grow_flower({x=pos.x+math.random(10)-5,y=pos.y+math.random(10)-5,z=pos.z+math.random(10)-5})
			end
		end,
	})
	
	minetest.register_abm({
		interval = flower[8],
		chance = flower[9],
		nodenames = {"flowers:"..flower[2]},
		action = function(pos, node, active_object_count, active_object_count_wider)
			minetest.env:remove_node(pos)
		end,
	})
end