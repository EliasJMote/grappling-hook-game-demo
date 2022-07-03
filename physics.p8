pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- rectangular collision
function act_col(a,b)
    if(a.x<=b.x+b.w and a.x+a.w>=b.x and a.y<=b.y+b.h and a.y+a.h>=b.y) then
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

	if(p.hook.max_distance > 45) then
		p.hook.max_distance = 45
	end

	-- if the player is not currently hooked onto something, or the player is hooked and on the ground
	if (player.hook.is_hooked == false and player.has_momentum == false) then-- or (player.hook.is_hooked and player.is_on_ground) then

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

		if(btn(0) and p.x > 0 and p.dx > 0) then
			p.dx -= 0.01
			p.dir = "left"
		elseif(btn(1) and p.x < 128*8-8 and p.dx < 0) then
			p.dx += 0.01
			p.dir = "right"
		end

		-- if the player is off the ground
		--if not (p.is_on_ground) then

			-- if the player presses up, shorten the rope length
			if(btnp(2)) then

				--if (not solid_area(p.x+p.dx,p.y+p.dy-0.5,p.w,p.h) and p.hook.distance <= p.hook.max_distance) then

					p.hook.distance -= 2
					p.hook.max_distance -= 2
					if(p.hook.max_distance < 10) then
						p.hook.max_distance = 10
					end
					p.dy /= 2
				--end

			elseif(btnp(3)) then
				--if (not solid_area(p.x+p.dx,p.y+p.dy+0.5,p.w,p.h) and p.hook.distance <= p.hook.max_distance) then

					p.hook.distance += 2
					p.hook.max_distance += 2
					if(p.hook.max_distance > 45) then
						p.hook.max_distance = 45
					end
					p.dy /= 2
				--end

			elseif(btnp(0) and p.hook.distance <= p.hook.max_distance and not solid_area(p.x+p.dx,p.y+p.dy,p.w,p.h)) then
				p.dx -= 1
			elseif(btnp(1) and p.hook.distance <= p.hook.max_distance and not solid_area(p.x+p.dx,p.y+p.dy,p.w,p.h)) then
				p.dx += 1
			end
		--end

		-- if the player is on the ground

	end

	-- player jump
	if(btnp(4) and p.is_on_ground and not p.hook.is_hooked) then
		p.dy = p.jump_speed or -3.5
		p.is_jumping = true
		p.is_falling = false
		p.is_on_ground = false
		p.has_momentum = false
	end

	-- player stops jumping
	if(p.is_jumping and not p.is_falling and not btn(4)) then
		p.dy = 0
		p.is_falling = true
		p.has_momentum = false
	end

	if(p.is_on_ground) then
		p.has_momentum = false
	end

	local max_spd = 4

	if(p.dx < -max_spd) then p.dx = -max_spd end
	if(p.dx > max_spd)  then p.dx =  max_spd end
	if(p.dy < -max_spd) then p.dy = -max_spd end
	if(p.dy > max_spd)  then p.dy =  max_spd end

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

	if(not act.hook.is_hooked) then
		if(act.dy >= 0 and act.dy <= 0.3 and act.is_jumping) then
			act.is_jumping = false
			act.is_falling = true
		end
	end

	if(act.is_solid) then
		--if not solid_area(act.x+act.dx,act.y+act.dy,act.w,act.h) then
		if not solid_area(act.x+act.dx,act.y,act.w,act.h) then
			act.x += act.dx
		else
			act.dx = 0
		end

		if not solid_area(act.x,act.y+act.dy,act.w,act.h) then
		--if not solid_area(act.x+act.dx,act.y+act.dy,act.w,act.h) then
			act.y += act.dy
		else
			if(act.is_falling) then
				act.is_falling = false

				-- if falling, move the actor to the top of the block
				local block_y = get_block_y(act.y+act.dy+8)
				act.y = block_y - act.h - 1
				act.has_momentum = false
			end

			-- the player is on a solid block, so fall speed is set to 0
			act.dy = 0
			act.has_momentum = false
		end
	else
		act.x += act.dx
		act.y += act.dy
	end

	-- gravity
	if((act.is_falling or act.is_jumping or not act.is_on_ground) and act.dy < 3) then
		act.dy += act.gravity or 0.3
	end

	return act
end