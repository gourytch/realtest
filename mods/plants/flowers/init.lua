--description; name; reproduction: texture; number_of_flowers, interval, chance, radius; death: interval, chance; light; grounds;
local flowers = {
	{"Camomile", "camomile", "flowers_camomile.png", 2, 1, 10, 5, 1, 10, 8, {"default:dirt", "default:dirt_with_grass", "default:dirt_with_clay", "default:dirt_with_grass_and_clay"}}
}

realtest.registered_flowers = {}
realtest.registered_flowers_list = {}
function realtest.register_flower(name, FlowerDef)
	local flower = {
		name = name,
		description = FlowerDef.description or "Flower",
		inventory_image = FlowerDef.inventory_image or "wieldhand.png",
		grounds = FlowerDef.grounds or {"default:dirt", "default:dirt_with_grass", "default:dirt_with_clay", "default:dirt_with_grass_and_clay"},
		min_lighting = FlowerDef.min_lighting or 8,
		grow_interval = FlowerDef.grow_interval or 1000,
		grow_chance = FlowerDef.grow_chance or 5,
		death_cause = FlowerDef.death_cause or
		function(flowers_around)
			if #flowers_around > 5 then
				return true
			end
			return false
		end,
		grow_cause = FlowerDef.grow_cause or
		function(flowers_around)
			if #flowers_around >= 1 and #flowers_around <= 5 then
				return true
			end
			return false
		end
	}
	flower.textures = FlowerDef.textures or {flower.inventory_image}
	realtest.registered_flowers[name] = flower
	realtest.registered_flowers_list:insert(name)
end

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
		groups = {dig_immediate=3,dropping_node=1},
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
			local n = minetest.env:find_nodes_in_area({x=pos.x-2,y=pos.y-2,z=pos.z-2}, {x=pos.x+2,y=pos.y+2,z=pos.z+2}, node.name)
			if #n > 5 then
				minetest.env:remove_node(pos)
			elseif #n >= 1 then
				grow_flower({x=pos.x+math.random(10)-5,y=pos.y+math.random(10)-5,z=pos.z+math.random(10)-5})
			end
		end,
	})
	
	--[[minetest.register_abm({
		interval = flower[8],
		chance = flower[9],
		nodenames = {"flowers:"..flower[2]},
		action = function(pos, node, active_object_count, active_object_count_wider)
			minetest.env:remove_node(pos)
		end,
	})]]
end