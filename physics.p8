pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- rectangular collision
function act_col(a,b)
    if(a.x<b.x+b.w and a.x+a.w>b.x and a.y<b.y+b.h and a.y+a.h>b.y) then
    	return true
    end
    return false
end

-- check if a map cell is solid
function solid(x,y)
	
	if(fget(mget(flr(x/8),flr(y/8)),0)) then
		return true
	end
	return false
end

-- check if the area is solid
function solid_area(x,y,w,h)
	return solid(x+w,y) or solid(x+w,y+h) or solid(x,y) or solid(x,y+h)
end

function get_block_y(y)
	return y-y%8
end

-- player keyboard commands
function player_controls(p)
	local spd = 1

	
	--if(btn(0) and p.x > cam.x) then

	-- if the player is not currently hooked onto something
	if not (player.hook.is_hooked) then

		-- player horizontal movement
		if(btn(0) and p.x > 0) then
			p.dx = -spd
			p.dir = "left"
		elseif(btn(1) and p.x < 128*8-8) then
			p.dx = spd
			p.dir = "right"
		else
			p.dx = 0
		end

	-- if the player is currently hooked onto something
	else

		-- if the player is off the ground
		--if not (p.is_on_ground) then

			-- if the player presses up, shorten the rope length
			if(btn(2)) then

				if not solid_area(p.x,p.y-0.5,p.w,p.h) then

					p.hook.distance -= 0.5
					p.y -= 0.5
				end

			elseif(btn(3)) then
				if not solid_area(p.x,p.y+0.5,p.w,p.h) then

					p.hook.distance += 0.5
					p.y += 0.5
				end
			end
		--end

		-- if the player is on the ground

	end

	-- player jump
	if(btnp(2) and p.is_on_ground and not p.hook.is_hooked) then
		p.dy = -3.75
		p.is_jumping = true
		p.is_falling = false
		p.is_on_ground = false
	end

	-- player stops jumping
	if(p.is_jumping and not p.is_falling and not btn(2)) then
		p.dy = 0
		p.is_falling = true
	end

	return p
end

-- move the player, an npc or an enemy
function move_actor(act)

	-- check if the actor is on the ground
	if not solid_area(act.x,act.y+act.dy+1,act.w,act.h) then
		act.is_on_ground = false
	elseif(act.dy >= 0) then
		act.is_on_ground = true
	end

	if(act.dy >= 0 and act.dy <= 0.3 and act.is_jumping) then
		act.is_jumping = false
		act.is_falling = true
	end

	if(act.is_solid) then
		if not solid_area(act.x+act.dx,act.y,act.w,act.h) then
			act.x += act.dx
		else
			act.dx = 0
		end

		if not solid_area(act.x,act.y+act.dy,act.w,act.h) then
			act.y += act.dy
		else
			if(act.is_falling) then
				act.is_falling = false

				-- if falling, move the actor to the top of the block
				local block_y = get_block_y(act.y+act.dy+8)
				act.y = block_y - act.h - 1
			end

			-- the player is on a solid block, so fall speed is set to 0
			act.dy = 0
		end
	else
		act.x += act.dx
		act.y += act.dy
	end

	-- gravity
	if((act.is_falling or act.is_jumping or not act.is_on_ground) and act.dy < 3) then
		act.dy += 0.3
	end

	return act
end