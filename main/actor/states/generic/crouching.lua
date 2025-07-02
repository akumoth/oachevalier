local state = require('main.actor.states.state')
local class = require('main.utils.class')

local crouching = class.new_class({});

function crouching.new(movement, collision, inputs, fsm)
	local crouching_state = state(
	{
		name = 'crouching',
		enter = function(self, from)
			collision.push = true
			
			-- Eventually, the calls to change the current sprite animation should be done by the
			-- state machine (barring idk, attack state) once there is an animation for each one
			
			if (from == 'idle' or from == 'foxtrot' or from == 'walking') then
				sprite.play_flipbook("spr#spr", hash("stand_to_crouch"))
			else
				sprite.play_flipbook("spr#spr", hash("crouch"))
			end
			 
			collision.do_snap = true
			-- While on the ground, the actor's speed is always angled slightly towards the ground 
			-- to get them colliding into slopes.
			if (from ~= 'foxtrot') then
				movement:update_vertical_speed(movement.slope_suck)
				movement:update_horizontal_speed(0)
			end
		end,
		exit = function() end,
		update = function(dt) 

			local slope = collision.slope_down or collision.slope_up
			
			if movement.speed.x ~= 0 then
				if math.abs(vmath.length(movement.speed)) > ((slope) and 90 or 20) then
					movement:change_speed_length(-(vmath.length(movement.speed) / 4))
					movement:update_horizontal_speed(vmath.length(movement.speed) * math.abs(movement.speed.x)/movement.speed.x, true)
				else
					movement:reset_speed()
				end
			end

			if movement.move_dir.x ~= 0 then
				movement:update_facing_dir()
			end
			
			if not inputs.down() then
				fsm:stop()
			end
			
			-- The collision object's "is_falling" message takes care of switching to the falling
			-- state. This has the side effect of giving around 2-3 frames of coyote time.
			if not collision.contact.d then 
				movement:apply_gravity()
			end
			
		end
	})
	local self = setmetatable(crouching_state, crouching)
	self._index = self
	return self
end

return crouching