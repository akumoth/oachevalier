local state = require('main.actor.states.state')
local class = require('main.utils.class')
local angle = require('main.utils.angle')

local teching = class.new_class({});

function teching.new(movement, collision, inputs, fsm, hitboxman)
	local teching_state = state({
		name = 'teching',
		enter = function (self, from)
			collision.push = false
			
			hitboxman:reset()
			hitboxman.ignore_update = true
			
			sprite.play_flipbook("spr#spr", hash("air"))
			-- applying tint while player is invulnerable
			go.set("spr#spr", "tint", vmath.vector4(0.5, 0.5, 0.5, 1))
			
			self.vals.dir = inputs.get_tech_dir()

			self.vals.air = not collision.contact.d
			
			movement:reset_speed()
			
			if self.vals.air then
				fsm.state_duration = movement.air_tech_time 
				if self.vals.dir == hash("moveLeft") or self.vals.dir == hash("moveRight") then
					local flip = self.vals.dir == hash("moveLeft")
					local tech_angle = ((flip) and angle:flip_angle(movement.tech_angle,"h") or movement.tech_angle)
					movement:update_horizontal_speed(movement.up_tech_speed*.6)
					movement:rotate_dir(tech_angle*math.pi/180)
					self.vals.teched = true
				elseif self.vals.dir == hash("moveUp") then
					collision.do_snap = false
					movement:update_vertical_speed(movement.up_tech_speed*.8)
					self.vals.teched = true
				end
			elseif self.vals.dir == hash("moveLeft") or self.vals.dir == hash("moveRight") then
				fsm.state_duration = movement.side_tech_time
			elseif self.vals.dir == hash("moveUp") then
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
			go.set("spr#spr", "tint", vmath.vector4(1, 1, 1, 1))
			
		end,
		update = function (self, dt)
			if not self.vals.teched and not self.vals.air then
				if self.vals.dir == hash("moveLeft") or self.vals.dir == hash("moveRight") then
					if fsm.state_duration < 16 then
						self.vals.teched = true
						collision.do_snap = true
						local flip = self.vals.dir == hash("moveLeft")
						movement:update_horizontal_speed((flip) and -movement.side_tech_speed or movement.side_tech_speed)
					end
				elseif self.vals.dir == hash("moveUp") then
					if fsm.state_duration < 12 then
						self.vals.teched = true
						collision.do_snap = false
						movement:reset_speed()
						movement:update_vertical_speed(movement.up_tech_speed)
						print("HELLO!")
					end
				end
			end

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
		end,
		vals = {
			teched = false
		}
	})
	local self = setmetatable(teching_state, teching)
	self._index = self
	return self
end

return teching