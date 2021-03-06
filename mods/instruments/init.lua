instruments = {}
instruments.spear = {}

instruments.spear.damage = 10
instruments.spear.gravity = 9
instruments.spear.velocity = 19

instruments.materials = {
	"stone",
	"bismuth",
	"zinc",
	"tin",
	--------
	"copper",
	--------
	"rose_gold",
	"black_bronze",
	"bismuth_bronze",
	"bronze",
	"aluminium",
	--------
	"wrought_iron",
	--------
	"steel",
	--------
	"black_steel",
}

instruments.desc_list = {
	"Stone",
	"Bismuth",
	"Zinc",
	"Tin",
	--------
	"Copper",
	--------
	"Rose Gold",
	"Black Bronze",
	"Bismuth Bronze",
	"Bronze",
	"Aluminium",
	--------
	"Wrought Iron",
	--------
	"Steel",
	--------
	"Black Steel",
}

instruments.stone_head_recipes = {
	pick = {{{"default:cobble","default:cobble","default:cobble"}},3},
	axe = {{{"default:cobble","default:cobble"}},2},
	shovel = {{{"default:cobble","default:cobble"},{"default:cobble","default:cobble"}},4},
	hammer = {{{"default:cobble","default:cobble","default:cobble"},{"default:cobble","default:cobble","default:cobble"}},6},
}

instruments.levels = {0,0,0,0,1,2,2,2,2,2,3,4,5}

instruments.durability = {50, 211, 281, 296, 411, 521, 531, 581, 601, 731, 801, 1101, 1501}

instruments.list = {"pick", "axe", "shovel", "hammer", "sword", "spear", "chisel"}

instruments.spear.entity = {
	physical = false,
	timer=0,
	textures = {"instruments_spear_back.png"},
	lastpos={},
	collisionbox = {0,0,0,0,0,0},
	material = "stone",
}

instruments.spear.entity.on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.env:get_node(pos)

	if self.timer>0.2 then
		local objs = minetest.env:get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 2)
		for k, obj in pairs(objs) do
			obj:set_hp(obj:get_hp()-instruments.spear.damage)
			if obj:get_entity_name() ~= "instruments:spear_entity" then
				minetest.env:add_item(self.lastpos, "instruments:spear_"..self.object:get_luaentity().material)
				self.object:remove()
			end
		end
	end

	if self.lastpos.x~=nil then
		if node.name ~= "air" then
			minetest.env:add_item(self.lastpos, "instruments:spear_"..self.object:get_luaentity().material)
			self.object:remove()
		end
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z}
end

minetest.register_entity("instruments:spear_entity", instruments.spear.entity)

dofile(minetest.get_modpath("instruments").."/groupcaps.lua")
dofile(minetest.get_modpath("instruments").."/buckets.lua")

for i, material in ipairs(instruments.materials) do
	--Spears
	minetest.register_tool("instruments:spear_"..material, {
		description = instruments.desc_list[i].." Spear",
		inventory_image = "instruments_spear_"..material..".png",
		on_use = function (item, player, pointed_thing)
			local playerpos=player:getpos()
			local obj=minetest.env:add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, "instruments:spear_entity")
			local dir=player:get_look_dir()
			obj:setvelocity({x=dir.x*instruments.spear.velocity, y=dir.y*instruments.spear.velocity, z=dir.z*instruments.spear.velocity})
			obj:setacceleration({x=dir.x*-3, y=-instruments.spear.gravity, z=dir.z*-3})
			obj:get_luaentity().material = material
			return ""
		end,
		groups = {material_level=instruments.levels[i], durability=instruments.durability[i], spear=1},
	})
	--Chisels (stone chisels are not exist)
	if material ~= "stone" then
		minetest.register_tool("instruments:chisel_"..material, {
			description = instruments.desc_list[i].." Chisel",
			inventory_image = "instruments_chisel_"..material..".png",
			on_use = function (item, player, pointed_thing)
				if pointed_thing.type ~= "node" then
					return
				end
				local n_name = minetest.env:get_node(pointed_thing.under).name
				if  n_name == "default:stone" then
					minetest.env:add_node(pointed_thing.under, {name="default:stone_flat"})
				elseif n_name == "default:desert_stone" then
					minetest.env:add_node(pointed_thing.under, {name="default:desert_stone_flat"})
				elseif n_name == "default:cobbleblock" then
					minetest.env:add_node(pointed_thing.under, {name="default:cobbleblock_flat"})
				end
				
				item:add_wear(65535/instruments.durability[i])
				return item
			end,
			groups = {material_level=instruments.levels[i], durability=instruments.durability[i], chisel=1},
		})
	end
	--Heads
	for j, instrument in ipairs(instruments.list) do
		if not (material == "stone" and (instrument == "chisel" or instrument == "sword" or instrument == "spear")) then
			minetest.register_craftitem("instruments:"..instrument.."_"..material.."_head", {
				description = instruments.desc_list[i].." "..instrument:capitalize() .. " Head",
				inventory_image = "instruments_"..instrument.."_"..material.."_head.png",
			})
			if material == "stone" then
				minetest.register_craft({
				output = "instruments:"..instrument.."_"..material.."_head "..instruments.stone_head_recipes[instrument][2],
				recipe = instruments.stone_head_recipes[instrument][1],
			})
			end
			minetest.register_craft({
				output = "instruments:"..instrument.."_"..material,
				recipe = {
					{"instruments:"..instrument.."_"..material.."_head"},
					{"group:stick"},
				},
			})
		end
	end
	--Instruments (without chisels and spears)
	for j, instrument in ipairs({"pick", "axe", "shovel", "hammer", "sword"}) do
		--Stone swords are not exist
		if not (material == "stone" and instrument == "sword") then
			minetest.register_tool("instruments:"..instrument.."_"..material, {
				description = instruments.desc_list[i].." "..instrument:capitalize(),
				inventory_image = "instruments_"..instrument.."_"..material..".png",
				tool_capabilities = {
					max_drop_level=1,
					groupcaps=instruments.groupcaps[j][i],
				},
				groups = {material_level=instruments.levels[i], durability=instruments.durability[i], [instrument] = 1},
			})
		end
	end
end

minetest.register_craft({
	output = "instruments:spear_stone",
	recipe = {
		{"default:cobble", "", ""},
		{"", "group:stick", ""},
		{"","","group:stick"},
	},
})
