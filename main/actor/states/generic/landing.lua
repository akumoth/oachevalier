local state = require('main.actor.states.state')
local class = require('main.utils.class')

local landing = class.new_class({});


function landing.new(movement, collision, inputs, fsm, hitboxman)
	local landing_state = state(
	{
		name = 'landing',
		enter = function(from)
			sprite.play_flipbook("spr#spr", hash("landing"))

			collision.push = true
			collision.do_snap = true

			movement:update_vertical_speed(movement.slope_suck)

			if hitboxman.cancel_land then
				fsm.state_duration = hitboxman.base_land_lag
			else
				fsm.state_duration = hitboxman.cur_land_lag
			end
		end,
		exit = function() end,
		update = function(dt) 
			local slope = collision.slope_left or collision.slope_right or collision.slope_upleft or collision.slope_upright
			
			if math.abs(vmath.length(movement.speed)) > ((slope) and 90 or 20) then
				movement:change_speed_length(-(vmath.length(movement.speed) / 4))
				movement:update_horizontal_speed(vmath.length(movement.speed) * math.abs(movement.speed.x)/movement.speed.x, true)
			else
				movement:reset_speed()
			end

			if not collision.contact.d then 
				movement:apply_gravity()
			end

			if fsm.state_duration < 1 then
				if inputs.down() then
					fsm:crouch()
				elseif movement.move_dir.x == 0 then 
					fsm:stop()
				else
					fsm:walk()
				end
			end
		end
	})
	local self = setmetatable(landing_state, landing)
	self._index = self
	return self
end

return landing