local state = require('main.actor.states.state')
local class = require('main.utils.class')

local knockdown = class.new_class({});

function knockdown.new(movement, collision, inputs, fsm, hitboxman)
	local knockdown_state = state({
		name = 'knockdown',
		enter = function (self, from)
			hitboxman:reset()
			hitboxman.ignore_update = true
			
			fsm.state_duration = 10
		end,
		exit = function (self, to) 
			if to ~= "teching" then hitboxman.ignore_update = false end
		end,
		update = function (self, dt) 
			if movement.speed.x ~= 0 then
				movement:update_horizontal_speed(0)
			end
			
			if not collision.contact.d then 
				movement:apply_gravity()
			end
			
			if fsm.state_duration < 1 then
				fsm:tech()
			end
		end,
		vals = {}
	})
	local self = setmetatable(knockdown_state, knockdown)
	self._index = self
	return self
end

return knockdown