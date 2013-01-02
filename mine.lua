--[[
Slots:
1 - diamond ore or another block that turtle must avoid
2 - filler block for making tonnels through liquids
3 - torches or another light source
4 - chests for unload mined resources

TODO:
- possibility to change dist via argument
- unloading in the chest
- 
--]]

-- config --
dist = 50 --length of tonnel

-- initialisation --
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

while i < dist do
	
	if not turtle.compareDown() then
		if turtle.digDown()
	end
	
	if not turtle.compareUp() then
		if not turtle.detectUp() and turtle.digUp() then --blocking liquid
			print('liquid detected! trying to fix...')
			
			if turtle.getItemCount(2) < 8 then
				print('filler block running out!')
				exit()
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
				print('wrong height!')
				exit()
			end
		else -- or just digging
			turtle.digUp()
		end
	end
	
	if not turtle.compare() then
		turtle.dig()
	end

	if not turtle.forward() then
		failCount = failCount + 1
	else
		failCount = 0
	end
	
	if failCount > 10 then
		print('ca\'t move forward!')
		i = i + 9000
	end
	
	i = i + 1
	
	--turtle.turnLeft() and turtle.turnLeft() --for debug
end

print(dist,' blocks successfully pass!')