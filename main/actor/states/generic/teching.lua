local state = require('main.actor.states.state')
local class = require('main.utils.class')
local angle = require('main.utils.angle')

local teching = class.new_class({});

function teching.new(movement, collision, inputs, fsm, hitboxman)
	local teching_state = state({
		name = 'teching',
		enter = function (self, from)
			hitboxman:reset()
			hitboxman.ignore_update = true
			
			sprite.play_flipbook("spr#spr", hash("air"))

			self.vals.dir = inputs.get_tech_dir()

			self.vals.air = not collision.contact.d
			if self.vals.dir == hash("moveLeft") or self.vals.dir == hash("moveRight") then
				fsm.state_duration = movement.side_tech_time
			elseif self.vals.air or self.vals.dir == hash("moveUp") then
				fsm.state_duration = movement.up_tech_time 
			else
				fsm.state_duration = movement.neutral_tech_time
			end
			
		end,
		exit = function (self, to)
			hitboxman.ignore_update = false
			if to ~= "falling" then
				collision.do_snap = true
			end
		end,
		update = function (self, dt)
			if collision.contact.d then
				sprite.play_flipbook("spr#spr", hash("idle"))
			else
				movement:apply_gravity()
			end

			if fsm.state_duration < 1 then
				if collision.contact.d then
					if inputs.down() then
						fsm:crouch()
					elseif movement.move_dir.x == 0 then 
						fsm:stop()
					else
						fsm:walk()
					end
				else
					fsm:fall()
				end
			end
			
			if self.vals.dir == hash("moveLeft") or self.vals.dir == hash("moveRight") then
				if fsm.state_duration < 20 or self.vals.air then
					
					if self.vals.air and not self.vals.teched then
						local flip = (self.vals.dir == hash("moveLeft") and movement.facing_dir.x == 1) or (self.vals.dir == hash("moveRight") and movement.facing_dir.x == -1)
						local tech_angle = ((flip) and angle:flip_angle(angle:flip_angle(movement.tech_angle,"h"),"v") or movement.tech_angle)
						movement:reset_speed()
						movement:update_horizontal_speed(movement.up_tech_speed)
						movement:rotate_dir(tech_angle*math.pi/180)
						self.vals.teched = true
					elseif not self.vals.air then
						collision.do_snap = true
						local flip = self.vals.dir == hash("moveLeft")
						movement:update_horizontal_speed((flip) and -movement.side_tech_speed or movement.side_tech_speed)

					end
				end
			elseif self.vals.dir == hash("moveUp") or self.vals.air then
				if (fsm.state_duration < 16 or self.vals.air) and not self.vals.teched then
					collision.do_snap = false
					movement:reset_speed()
					movement:update_vertical_speed(movement.up_tech_speed*1.1)
					self.vals.teched = true
				end
			end
		end,
		vals = {}
	})
	local self = setmetatable(teching_state, teching)
	self._index = self
	return self
end

return teching