local state = require('main.actor.states.state')
local class = require('main.utils.class')

local walking = class.new_class({});

function walking.new(movement, collision, inputs, fsm)
	local walking_state = state(
	{
		name = 'walking',
		enter = function() 
			sprite.play_flipbook("spr#spr", hash("walk"))
			collision.do_snap = true
			movement:update_vertical_speed(movement.slope_suck)
		end,
		exit = function()
			sprite.play_flipbook("spr#spr", hash("idle"))
		end,
		update = function(dt)
			if movement.move_dir.x ~= 0 then
				collision:check_push(movement)
				
				movement:update_horizontal_speed(movement.walk_speed * movement.move_dir.x)
				
				movement:update_vertical_speed(movement.slope_suck)
				movement:update_facing_dir()
				
				if not collision.contact.d then 
					movement:apply_gravity()
				end
			else
				fsm:stop()
			end
		end
	})
	local self = setmetatable(walking_state, walking)
	self._index = self
	return self
end

return walking