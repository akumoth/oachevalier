local state = require('main.actor.states.state')
local class = require('main.utils.class')

local idle = class.new_class({});

function idle.new(movement, collision, inputs, fsm)
	local idle_state = state(
	{
		name = 'idle',
		enter = function(self, from)
			-- Eventually, the calls to change the current sprite animation should be done by the
			-- state machine (barring idk, attack state) once there is an animation for each one
			if (from == 'crouching') then
				sprite.play_flipbook("spr#spr", hash("crouch_to_stand"))
			else
				sprite.play_flipbook("spr#spr", hash("idle"))
			end
			
			collision.do_snap = true
			-- While on the ground, the actor's speed is always angled slightly towards the ground 
			-- to get them colliding into slopes.
			movement:update_vertical_speed(movement.slope_suck)
			movement:update_horizontal_speed(0)
		end,
		exit = function() end,
		update = function(dt) 
			-- Always make sure the player's horizontal speed is 0 if they aren't doing anything.
			if movement.speed.x ~= 0 then
				movement:update_horizontal_speed(0)
			end

			collision:check_push(movement)
			
			-- The collision object's "is_falling" message takes care of switching to the falling
			-- state. This has the side effect of giving around 2-3 frames of coyote time.
			if not collision.contact.d then 
				movement:apply_gravity()
			end
		end
	})
	local self = setmetatable(idle_state, idle)
	self._index = self
	return self
end

return idle