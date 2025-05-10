local state = require('main.actor.states.state')
local class = require('main.utils.class')

local airdashing = class.new_class({});

function airdashing.new(movement, collision, inputs, fsm)
	local airdashing_state = state({
		name = 'airdashing',
		enter = function (self, from)
			sprite.play_flipbook("spr#spr", hash("air"))
			self.vals.dir = inputs.get_airdash_dir()
			fsm.can_airdash = false

			movement.ignore_gravity = true
			collision.no_reset = true
			movement:update_horizontal_speed(0)
			movement:update_vertical_speed(0)
			fsm.state_duration = 35

			local penalty = 0

			if self.vals.dir == hash("moveLeft") then
				if movement.facing_dir.x == 1 then penalty = 110 end
				movement:update_horizontal_speed(-movement.airdash_speed + penalty)
			elseif self.vals.dir == hash("moveUp") then
				movement:update_vertical_speed(movement.airdash_speed)
			elseif self.vals.dir == hash("moveDown") then
				movement:update_vertical_speed(-movement.airdash_speed - 100)
			elseif self.vals.dir == hash("moveRight") then
				if movement.facing_dir.x == -1 then penalty = -110 end
				movement:update_horizontal_speed(movement.airdash_speed + penalty)
			end
		end,
		exit = function (self, to)
			movement.speed.x = movement.speed.x * .75
			movement.ignore_gravity = false
			collision.no_reset = false
		end,
		update = function (self, dt)
			local dir = movement.facing_dir.x
			local angle_q = (math.pi/2)/10

			if self.vals.dir == hash("moveLeft") or self.vals.dir == hash("moveRight") then
				if fsm.state_duration < 18 and fsm.state_duration > 10 then
					movement:rotate_dir(-angle_q * dir)
				end
			elseif self.vals.dir == hash("moveUp") or self.vals.dir == hash("moveDown") then
				if fsm.state_duration < 22 and fsm.state_duration > 12 then
					movement:rotate_dir(angle_q * dir)
				end
			end

			if self.vals.dir ~= hash("moveDown") then
				movement.speed.y = math.max(movement.speed.y, movement.fall_speed)
			end

			if collision.contact.d then
				if movement.move_dir.x == 0 then 
					fsm:stop()
				else
					fsm:walk()
				end
			end

			if fsm.state_duration < 1 then
				fsm:fall()
			end
		end,
		vals = {
			dir = hash("moveLeft")
		}
	})
	local self = setmetatable(airdashing_state, airdashing)
	self._index = self
	return self
end

return airdashing