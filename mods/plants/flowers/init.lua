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
		texture = FlowerDef.texture,
		grounds = FlowerDef.grounds or {"default:dirt", "default:dirt_with_grass", "default:dirt_with_clay", "default:dirt_with_grass_and_clay"},
		grow_light = FlowerDef.grow_light or 8,
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
		end,
		extra_definition_items = FlowerDef.extra_definition_items or {}
	}
	realtest.registered_flowers[name] = flower
	table.insert(realtest.registered_flowers_list,name)
	local NodeDef = {
		description = flower.description,
		drawtype = "plantlike",
		tiles = {flower.texture},
		inventory_image = flower.texture,
		wield_image = flower.texture,
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		groups = {dig_immediate=3,dropping_node=1,flower=1},
		selection_box = {
			type = "fixed",
			fixed = {-0.2, -0.5, -0.2, 0.2, 0.2, 0.2}
		}
	}
	for n, item in pairs(flower.extra_definition_items) do
		NodeDef[n] = item
	end
	minetest.register_node(name, NodeDef)
	minetest.register_abm({
		interval = flower.grow_interval,
		chance = flower.grow_chance,
		nodenames = {name},
		action = function(pos, node, active_object_count, active_object_count_wider)
			local n = minetest.env:find_nodes_in_area({x=pos.x-2,y=pos.y-2,z=pos.z-2}, {x=pos.x+2,y=pos.y+2,z=pos.z+2}, "group:flower")
			if flower.death_cause(n) then
				minetest.env:remove_node(pos)
			elseif flower.grow_cause(n) then
				local p = {x=pos.x+math.random(10)-5,y=pos.y+math.random(10)-5,z=pos.z+math.random(10)-5}
				if minetest.env:get_node(p).name ~= "air" then
					return
				end
				if not minetest.env:get_node_light(p) then
					return
				end
				if minetest.env:get_node_light(p) < flower.grow_light then
					return
				end
				if table.contains(flower.grounds, minetest.env:get_node({x=p.x,y=p.y-1,z=p.z}).name) then
					minetest.env:add_node(p, {name = name})
				end
			end
		end,
	})
end

realtest.register_flower("flowers:camomile", {
	description = "Camomile",
	texture = "flowers_camomile.png",
})