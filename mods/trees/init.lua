trees = {}

local function generate(tree, minp, maxp, seed)
	local perlin1 = minetest.env:get_perlin(329, 3, 0.6, 100)
	-- Assume X and Z lengths are equal
	local divlen = 16
	local divs = (maxp.x-minp.x)/divlen+1;
	for divx=0,divs-1 do
		for divz=0,divs-1 do
			local x0 = minp.x + math.floor((divx+0)*divlen)
			local z0 = minp.z + math.floor((divz+0)*divlen)
			local x1 = minp.x + math.floor((divx+1)*divlen)
			local z1 = minp.z + math.floor((divz+1)*divlen)
			-- Determine trees amount from perlin noise
			local trees_amount = math.floor(perlin1:get2d({x=x0, y=z0}) * 5 + 0)
			-- Find random positions for trees based on this random
			local pr = PseudoRandom(seed)
			for i=0,trees_amount do
				local x = pr:next(x0, x1)
				local z = pr:next(z0, z1)
				-- Find ground level (0...30)
				local ground_y = nil
				for y=30,0,-1 do
					if minetest.env:get_node({x=x,y=y,z=z}).name ~= "air" then
						ground_y = y
						break
					end
				end
				if ground_y then
					if table.contains(tree.grounds,minetest.env:get_node({x=x,y=ground_y,z=z}).name) and
							not minetest.env:find_node_near({x=x,y=ground_y,z=z}, tree.radius, tree.treedef.leaves) then
						minetest.env:spawn_tree({x=x,y=ground_y+1,z=z},tree.treedef)--trees.make_tree({x=x,y=ground_y+1,z=z}, tree)
					end
				end
			end
		end
	end
end

dofile(minetest.get_modpath("trees").."/registration.lua")

minetest.register_on_generated(function(minp, maxp, seed)
	local pr = PseudoRandom(seed)
	local n = 0
	if pr:next(1,2) == 1 then
		n = n + 1
	end
	if pr:next(1, 10) == 1 then
		n = n + 1
	end
	if pr:next(1, 20) == 1 then
		n = n + 1
	end
	if n > 0 then
		for i = 1, n do
			local n = pr:next(1,#realtest.registered_trees_list)
			local t = realtest.registered_trees_list[n]
			generate(realtest.registered_trees[t], minp, maxp, seed, 1/8/2, 1)
		end
	end
end)
