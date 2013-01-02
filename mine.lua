--[[
1 coal enough for a length of 19 to 96 "meters"
(it depends on the amount of liquid on the way)

Slots:
1  - diamond ore or another block that turtle must avoid
2  - filler block for making tonnels through liquids
3  - torches
4  - chests for unload mined resources
16 - coal or another fuel

Flags:
nochest, nc - program will be terminated if turtle's inventory is full.
passliquid, pl - turle will be digging in spite of liquids around.
fastmode, fm - disable a few difficult checks
--]]

-- config --
length = 40 --length of tonnel by default
faillimit = 10

-- initialisation --
local args = { ... }
arg1 = tonumber(args[1])

if args[1] ~= nil then
	if arg1 ~= nil then
		length = arg1
	elseif (args[1] == 'help') or (args[1] == '?') or (args[1] == '/?') then
		print('Usage: mine <(length_of_tonnel)> [flags]')
		print('type "mine flags" for more about flags')
		print('Slots:')
		print('1  - block that turtle shouldn\'t destroy (e.g. diamond ore)')
		print('2  - block for making tonnels through liquids (e.g. glass)')
		print('3  - torches')
		print('4  - chests for unload mined resources')
		print('16 - coal or another fuel [OPTIONAL]')
		do return end
	elseif 	(args[1] == 'flags') or (args[1] == 'f') then
		print('nochest, nc - program will be terminated if turtle\'s inventory is full.')
		print('passliquid, pl - turle will be digging in spite of liquids around.')
		print('fastmode, fm - disable a few difficult checks')
		do return end
	else
		print('Usage: mine [(length_of_tonnel)] [flags]')
		print('type "mine help" for full help')
		do return end
	end
end

for a,content in ipairs(args) do
  if (content == 'nochest') or (content == 'nc') then nochest = true end
  if (content == 'passliquid') or (content == 'pl') then passliquid = true end
  if (content == 'fastmode') or (content == 'fm') then fastmode = true else fastmode = false end
end

turtle.select(16)
turtle.refuel()
print("fuel level: ", turtle.getFuelLevel())
turtle.select(1)
i = 0
failCount = 0
height = 0
torch = 0

-- code --
function placeLeft()
	turtle.turnLeft()
	local flag = turtle.place()
	turtle.turnRight()
	return flag
end

function placeRight()
	turtle.turnRight()
	local flag = turtle.place()
	turtle.turnLeft()
	return flag
end

function blockLiquid()
	if passliquid then
		print('Liquid detected! Ingoring due to "passliqid" flag...')
	else
	print('Liquid detected! Trying to fix...')
	if turtle.getItemCount(2) < 8 then
		print('Filler block running out! Refill slot 2 and restart program.')
		do return 'blockingfail' end
	end
	
	turtle.select(2)
	if turtle.up() then	height = height + 1	end
	turtle.placeUp()
	placeLeft()
	placeRight()
	if turtle.down() then height = height - 1 end
	placeLeft()
	placeRight()
	if turtle.down() then height = height - 1 end
	placeLeft()
	placeRight()
	turtle.placeDown()
	if turtle.up() then	height = height + 1	end		
	turtle.select(1)
	
	if height ~= 0 then
		print('Wrong height!')
		do return end
	end
	end
end

while i < length do
	
	if not turtle.compareDown() then
		turtle.digDown()
	end
	
	if not turtle.compareUp() then
		if not turtle.detectUp() and turtle.digUp() then --blocking liquid
			if blockLiquid() == 'blockingfail' then
					do return end
			end
		else -- or just digging
			turtle.digUp()
			if not fastmode then sleep(0.4) end
			for fail = 0,faillimit do			
			if not turtle.detectUp() and turtle.digUp() then --blocking liquid
				if blockLiquid() == 'blockingfail' then
					do return end
				end
				break
			end
			
			if not turtle.detectUp() and not turtle.digUp() then
				break
			end
			
			turtle.digUp()
			
			if fail == faillimit then
				print('Something strange above. Help me, master!')
				do return end
			end
			end
		end
	end
	
	if torch < 8 then --torch placing
		torch = torch + 1
	else
		turtle.turnRight()
		turtle.turnRight()
		turtle.select(3)
		turtle.place()
		turtle.select(1)
		turtle.turnRight()
		turtle.turnRight()
		torch = 0
	end
	
	if turtle.getItemCount(16)>0 then --unloading mined resources
		print('Invenory is full! Slot 4 must contain a chest. Trying to unloading items...')
		if nochest then
			print('Chests was denied by "nochest" flag! Clear inventory and restart program.')
			do return end
		end
		turtle.select(4)
		turtle.placeDown()
		for j = 5,16 do
			turtle.select(j)
			turtle.dropDown()
		end
		turtle.select(1)
    end
	
	if not turtle.compare() then
		for fail = 0,faillimit do --because it can be sand or gravel
			turtle.dig()
			if turtle.forward() then break end
			if fail == faillimit then
				print('Something strange in the front. Help me, master!')
				do return end
			end
		end
	else
		print('Block like in slot 1 detected, mine it and restart program.')
		do return end
	end
	
	i = i + 1
	if length == i then print(length,' blocks successfully pass!') end
end