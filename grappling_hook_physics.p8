pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
function grappling_hook_controls(p)

	-- launch the grappling hook
	if(btnp(5) and not p.hook.is_released) then
		p.hook.is_released = true

		if(p.dir == "right") then
			p.hook.angle = 0
		else
			p.hook.angle = 180
		end

		-- if the up key is held, shoot up
		if(btn(2)) then
			p.hook.angle = 90

			if(btn(0)) then
				p.hook.angle = 135
			elseif(btn(1)) then
				p.hook.angle = 45
			end

		-- if the down key is held, shoot down
		elseif(btn(3)) then
			p.hook.angle = 270

			if(btn(0)) then
				p.hook.angle = 225
			elseif(btn(1)) then
				p.hook.angle = 315
			end
		end
	end

	-- if the grappling hook button is let go, reset the hook
	if(not btn(5) and p.hook.is_released) then
		p.has_momentum = true
		p.hook.distance = 0
		--p.hook.max_distance = 0
		p.hook.timer = 0
		p.hook.is_released = false
		p.hook.is_hooked = false
		if(p.dy > 0) then
			p.is_falling = true
		end
	end

	-- if we are hooked and past the max distance
	if(p.hook.is_hooked and p.hook.distance >= p.hook.max_distance) then
		p.hook.distance = p.hook.max_distance

		if(p.dy > 0) then
			--p.dy = -(p.dy/2)-1
			p.dy = -p.dy
		end

		-- add horizontal momentum
		if(p.x < p.hook.x - 0.3) then
			p.dx += 0.3
		elseif(p.x > p.hook.x + 0.3) then
			p.dx -= 0.3
		else
			p.dx = 0
		end
	end

	return p
end

function update_grappling_hook(p)

	p.hook.init_x = player.x + 2
	p.hook.init_y = player.y + 2

	if(p.hook.is_hooked == false and p.hook.is_released) then

		p.hook.x = p.hook.init_x + p.hook.distance * cos(p.hook.angle/360)
		p.hook.y = p.hook.init_y + p.hook.distance * sin(p.hook.angle/360)

		-- if the hook has found purchase, we are now anchored to a point
		if solid_area(p.hook.x,p.hook.y,p.hook.w,p.hook.h) then
			p.hook.is_hooked = true
			p.hook.max_distance = p.hook.distance
			p.dx = 0
			p.dy = 0
			p.is_falling = false
			p.is_jumping = false
		end

		if(p.hook.timer <= 15) then
			p.hook.distance += 3
		else
			p.hook.distance -= 3
		end

		if(p.hook.timer >= 30) then
			p.hook.is_released = false
			p.hook.timer = 0
		end

		p.hook.timer += 1
	end

	-- update the hook distance if we are hooked
	if(p.hook.is_hooked) then
		local dx = p.hook.init_x - p.hook.x
		local dy = p.hook.init_y - p.hook.y
		p.hook.distance = sqrt(dx*dx+dy*dy)
	end

	return p
end