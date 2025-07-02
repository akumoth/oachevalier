local class = require('main.utils.class')
local hmath = require('main.utils.hmath')

local collision = class.new_class({})

local RAY_CAST_LEFT_ID = 1
local RAY_CAST_RIGHT_ID = 2
local RAY_CAST_UP_ID = 3
local RAY_CAST_UP_LEFT_ID = 4
local RAY_CAST_UP_RIGHT_ID = 5
local RAY_CAST_DOWN_ID = 6
local RAY_CAST_DOWN_LEFT_ID = 7
local RAY_CAST_DOWN_RIGHT_ID = 8

function collision.new(bounding_box, actor_collision_group)
	-- pass Defold-defined bounding box as argument
	local data = {}

	local bounds = {
		bottom = vmath.vector3(0, -bounding_box.dimensions.y/2, 0),
		top = vmath.vector3(0, bounding_box.dimensions.y/2, 0),
		left = vmath.vector3((-bounding_box.dimensions.x/2), 0, 0),
		right = vmath.vector3((bounding_box.dimensions.x/2), 0, 0),
	}

	local raycast_left = bounds.left
	local raycast_right = bounds.right
	local raycast_up = bounds.top
	local raycast_down = bounds.bottom
	local raycast_down_left = raycast_left
	local raycast_up_left = raycast_left
	local raycast_down_right = raycast_right
	local raycast_up_right = raycast_right

	data.bounds = {unpack(bounds)}
	data.rays = {
		raycast_left,
		raycast_right,
		raycast_up,
		raycast_up_left,
		raycast_up_right,
		raycast_down,
		raycast_down_left,
		raycast_down_right,
	}

	data.fall_buffer = 3
	data.falling_dur = 0
	data.contact = {
		l = false,
		r = false,
		u = false,
		d = false
	}
	
	data.do_snap = false
	data.snap_length = vmath.vector3(0,-15,0)
	
	data.slope_down = nil
	data.slope_up = nil

	data.col_group = actor_collision_group or {}

	data.push = true
	
	local self = setmetatable(data, collision)
	self._index = self
	return self
end

function collision:handle_collisions(origin, movement, debug)
	local offset = vmath.vector3()
	local previous_ground_contact = self.contact.d
	self.contact.u = false
	self.contact.d = false
	self.contact.l = false
	self.contact.r = false
	
	for id, ray in ipairs(self.rays) do
		local new_ray
		local result
		if id == RAY_CAST_DOWN_LEFT_ID or id == RAY_CAST_DOWN_RIGHT_ID then
			result = physics.raycast(origin + self.rays[RAY_CAST_DOWN_ID] + offset, origin + offset + ray, {hash("world")})
			new_ray = ray + self.rays[RAY_CAST_DOWN_ID]
		elseif id == RAY_CAST_UP_LEFT_ID or id == RAY_CAST_UP_RIGHT_ID then
			result = physics.raycast(origin + self.rays[RAY_CAST_UP_ID] + offset, origin + offset + ray, {hash("world")})
			new_ray = ray + self.rays[RAY_CAST_UP_ID]
		else
			result = physics.raycast(origin + offset, origin + offset + ray, {hash("world")})
		end	

		
		
		if result then
			
			local separation = (new_ray or ray) * (1 - result.fraction)
			--	Set slope data on collision object (to process when changing velocity and so on)
			self.slope_down = id == RAY_CAST_DOWN_ID and result.normal.x ~= 0 and result.normal.y ~= 0 and result.normal
			-- slope for up left and up right corners of the raycasts
			self.slope_up = id == RAY_CAST_UP_ID and result.normal.x ~= 0 and result.normal.y ~= 0 and result.normal
			
			if id == RAY_CAST_DOWN_ID then
				
				if result.normal.y > 0.7 and movement.speed.y <= 0 then
					self.contact.d = true
					separation.x = 0
				elseif result.normal.x ~= 0 then
					if self.contact.l or self.contact.r then
						separation.x = 0
						separation.y = 0
					else
						separation.y = 0
					end
				else
					separation.y = 0
					separation.x = 0
				end
			elseif id == RAY_CAST_UP_ID then
				
				if result.normal.y < -0.7 then	
					self.contact.u = true
					if self.contact.l or self.contact.r or result.fraction < 0.6 then
						if (movement.speed.x > 0 and separation.x > 0) or (movement.speed.x < 0 and separation.x < 0) then
							separation.x = 0
						end
						
						separation.y = 0
					end
					
				elseif result.normal.x ~= 0 then
					if self.contact.l or self.contact.r then
						separation.x = 0
						separation.y = 0
					else
						separation.y = 0
					end
				else
					separation.x = 0
					separation.y = 0
				end
			elseif id == RAY_CAST_LEFT_ID or id == RAY_CAST_RIGHT_ID then
				self.contact.l = id == RAY_CAST_LEFT_ID
				self.contact.r = id == RAY_CAST_RIGHT_ID
			elseif id == RAY_CAST_DOWN_LEFT_ID or id == RAY_CAST_DOWN_RIGHT_ID or id == RAY_CAST_UP_LEFT_ID or id == RAY_CAST_UP_RIGHT_ID then
				if result.fraction > 0 and not self.contact.l and not self.contact.r then
					local rev_result
					if id == RAY_CAST_DOWN_LEFT_ID or id == RAY_CAST_DOWN_RIGHT_ID then
						rev_result = physics.raycast(origin + offset + ray, origin + self.rays[RAY_CAST_DOWN_ID] + offset, {hash("world")})
					elseif id == RAY_CAST_UP_LEFT_ID or id == RAY_CAST_UP_RIGHT_ID then
						rev_result = physics.raycast(origin + offset + ray, origin + self.rays[RAY_CAST_UP_ID] + offset, {hash("world")})
					end
					if rev_result then
						local rev_separation = new_ray * (rev_result.fraction)
						separation = separation - rev_separation 
						separation.y = 0
					end
				end

				if result.normal.y == 0 then
					if id == RAY_CAST_UP_LEFT_ID or id == RAY_CAST_DOWN_LEFT_ID then
						self.contact.l = true
					elseif id == RAY_CAST_DOWN_RIGHT_ID or id == RAY_CAST_UP_RIGHT_ID then
						self.contact.r = true
					end
				end
			else
				separation.x = 0
				separation.y = 0
			end
			offset = offset - separation
		end
		
	end

	if not self.no_reset then
		if	(self.contact.l and movement.speed.x < 0) or 
		(self.contact.r and movement.speed.x > 0) then 
			movement:update_horizontal_speed(0) 
		end

		if (self.contact.u and movement.speed.y > 0) or 
		(not previous_ground_contact and self.contact.d and movement.speed.y < 0) then 
			movement:update_vertical_speed(0) 
		end
	end

	-- try to snap downwards
	if self.do_snap and not self.contact.d then
		local snap_vec = origin + offset + self.rays[RAY_CAST_DOWN_ID]

		local snap_result = nil

		local separation
		
		local result = physics.raycast(snap_vec, snap_vec + self.snap_length, {hash("world")})
		
		if result and result.fraction > 0.001 then
			snap_result = result.position
			separation = (self.snap_length) * (1 - result.fraction)
			self.slope_down = result.normal.x ~= 0 and result.normal.y ~= 0 and result.normal
		end

		if snap_result ~= nil then
			offset.y = offset.y + (self.snap_length.y - separation.y - 1)
			self.contact.d = true
		end
	end
	
	-- use a falling buffer, aka a bit of coyote time to handle slopes and stuff like that better
	if self.contact.d then
		self.falling_dur = 0
	else
		self.falling_dur = self.falling_dur + 1
	end

	if self.falling_dur > self.fall_buffer then
		self.slope_down = nil
		msg.post("#", "is_falling")
	end
	if debug then print(offset) end
	return offset
end

function collision:check_move_into_collision(movement_vector, ignore_ground)
	if ignore_ground == nil then ignore_ground = false end
	return (not ignore_ground and self.contact.d and movement_vector.y < -0) or 
	(self.contact.u and movement_vector.y > 0) or 
	(self.contact.l and movement_vector.x < 0) or
	(self.contact.r and movement_vector.x > 0)
end

function collision:show_debug_rays(origin)
	for id, ray in ipairs(self.rays) do
		msg.post("@render:", "draw_line", { start_point = origin, end_point = origin + ray, color = vmath.vector4(1, 0, 0, 1) })
	end
end

function collision:check_push(movement)
	local origin = vmath.vector3(go.get_world_position())
	
	local rays = {
		self.rays[RAY_CAST_RIGHT_ID],
		self.rays[RAY_CAST_LEFT_ID],
		self.rays[RAY_CAST_RIGHT_ID] -- last sweep raycast
	}


	for id, ray in ipairs(rays) do
		local new_ray = vmath.vector3(ray)
		if self.slope_down then
			new_ray.y = new_ray.x * self.slope_down.x
		end	
		
		local result = physics.raycast(
			origin + self.rays[RAY_CAST_DOWN_ID] + (id > 2 and -new_ray or vmath.vector3()), 
			origin + self.rays[RAY_CAST_DOWN_ID] + new_ray, 
			self.col_group)
		if result then
			local dir = (id == 1 and 1 or -1)
			if id > 2 then dir = (result.fraction < 0.5 and 1 or -1) end

			local push = go.get(msg.url(nil, result.id, "controller"), "push")

			if push then
				msg.post(msg.url(nil, result.id, "controller"), "collision_push", {
					direction = dir,
					fraction = result.fraction
				})

				local other_slope = go.get(msg.url(nil, result.id, "controller"), "slope_down")
				
				movement:set_push(vmath.vector3(
					movement.pusher_speed.x * (1-result.fraction) * -dir, 0, 0),
					other_slope ~= vmath.vector3() and other_slope)
				return true
			end
		end
	end
	
end

-- Updates the actor's current position based on their speed + any nearby walls or floors they need to be pushed by.
function collision:update_position(dt, movement, debug)
	local step = 3 -- 

	local p = go.get_position()

	local distance = (movement.speed + movement.push) * dt -- multiply by delta time to avoid funny CPU speed shenanigans (that's how it works, right?)
	
	if movement.stop > 0 then -- freeze movement for the frames specified by movement.stop
		movement.stop = movement.stop - 1
		distance = vmath.vector3()
	end

	local world_p = go.get_world_position()

	local steps = math.max(1,math.ceil(vmath.length(distance)/step))
	
	local origin = vmath.vector3(world_p)
	local offset

	local positions = {}
	
	for i=1,steps,1 do
		if distance ~= vmath.vector3() then
			distance = (movement.speed + movement.push) * dt
		end

		origin = origin + distance/steps
		offset = self:handle_collisions(origin, movement, debug)	
		
		go.set_position(p + (distance*i)/steps + offset)

		if self:check_move_into_collision(movement.speed, true) then
			break
		end
		
	end
end

function collision:check_close_to_ground(origin, distance)
	if distance == nil then distance = 30 end
	local distance_v = vmath.vector3(0,-distance,0)
	local result = physics.raycast(origin + self.rays[RAY_CAST_DOWN_ID], origin + self.rays[RAY_CAST_DOWN_ID] + distance_v, {hash("world")})
	return result ~= nil
end

return collision