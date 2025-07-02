local class = require('main.utils.class')
local machine = require('main.actor.states.state_machine')
local controller = class.new_class({})
local StatesTables = require('main.actor.states.states_tables')

local function init_states(data)
	data.fsm  = machine.create({
		initial = 'idle',
		events = {
			{ name = 'walk', from = 'idle', to = 'walking' },
			-- { name = 'walk', from = 'foxtrot', to = 'walking' },
			{ name = 'walk', from = 'attacking', to = 'walking' },
			{ name = 'walk', from = 'hitstunned', to = 'walking' },
			-- { name = 'walk', from = 'airdashing', to = 'walking' },
			{ name = 'walk', from = 'clashing', to = 'walking' },
			{ name = 'walk', from = 'teching', to = 'walking' },
			{ name = 'walk', from = 'landing', to = 'walking' },

			-- { name = 'step', from = 'idle', to = 'foxtrot' },
			-- { name = 'step', from = 'foxtrot', to = 'foxtrot' },
			-- { name = 'step', from = 'attacking', to = 'foxtrot' },
			-- { name = 'step', from = 'clashing', to = 'foxtrot' },

			{ name = 'jump', from = 'idle', to = 'jumping' },
			{ name = 'jump', from = 'walking', to = 'jumping' },
			-- { name = 'jump', from = 'foxtrot', to = 'jumping' },
			{ name = 'jump', from = 'clashing', to = 'jumping' },
			{ name = 'jump', from = 'crouching', to = 'jumping' },
			
			{ name = 'fall', from = 'idle', to = 'falling' },
			{ name = 'fall', from = 'walking', to = 'falling' },
			-- { name = 'fall', from = 'foxtrot', to = 'falling' },
			{ name = 'fall', from = 'jumping', to = 'falling' },
			-- { name = 'fall', from = 'airdashing', to = 'falling' },
			{ name = 'fall', from = 'attacking', to = 'falling' },
			{ name = 'fall', from = 'hitstunned', to = 'falling' },
			{ name = 'fall', from = 'clashing', to = 'falling' },
			{ name = 'fall', from = 'teching', to = 'falling' },
			{ name = 'fall', from = 'landing', to = 'falling' },
			{ name = 'fall', from = 'crouching', to = 'falling' },

			-- { name = 'airdash', from = 'falling', to = 'airdashing' },
			-- { name = 'airdash', from = 'attacking', to = 'airdashing' },

			{ name = 'stop', from = 'walking', to = 'idle' },
			-- { name = 'stop', from = 'foxtrot', to = 'idle' },
			-- { name = 'stop', from = 'airdashing', to = 'idle' },
			{ name = 'stop', from = 'attacking', to = 'idle' },
			{ name = 'stop', from = 'hitstunned', to = 'idle' },
			{ name = 'stop', from = 'clashing', to = 'idle' },
			{ name = 'stop', from = 'teching', to = 'idle' },
			{ name = 'stop', from = 'landing', to = 'idle' },
			{ name = 'stop', from = 'crouching', to = 'idle' },

			{ name = 'attack', from = 'idle', to = 'attacking' },
			{ name = 'attack', from = 'walking', to = 'attacking' },
			-- { name = 'attack', from = 'foxtrot', to = 'attacking' },
			{ name = 'attack', from = 'falling', to = 'attacking' },
			-- { name = 'attack', from = 'airdashing', to = 'attacking' },
			{ name = 'attack', from = 'attacking', to = 'attacking' },
			{ name = 'attack', from = 'crouching', to = 'attacking' },

			{ name = 'land', from = 'attacking', to = 'landing' },
			{ name = 'land', from = 'falling', to = 'landing' },

			{ name = 'clash', from = 'attacking', to = 'clashing' },

			{ name = 'hitstun', from = 'idle', to = 'hitstunned' },
			{ name = 'hitstun', from = 'walking', to = 'hitstunned' },
			-- { name = 'hitstun', from = 'foxtrot', to = 'hitstunned' },
			{ name = 'hitstun', from = 'jumping', to = 'hitstunned' },
			{ name = 'hitstun', from = 'falling', to = 'hitstunned' },
			-- { name = 'hitstun', from = 'airdashing', to = 'hitstunned' },
			{ name = 'hitstun', from = 'attacking', to = 'hitstunned' },
			{ name = 'hitstun', from = 'landing', to = 'hitstunned' },
			{ name = 'hitstun', from = 'hitstunned', to = 'hitstunned' },

			{ name = 'knockdown', from = 'hitstunned', to = 'knockdown' },

			{ name = 'tech', from = 'knockdown', to = 'teching' },
			{ name = 'tech', from = 'hitstunned', to = 'teching' },
			
			
			{ name = 'crouch', from = 'idle', to = 'crouching' },
			{ name = 'crouch', from = 'walking', to = 'crouching' },
			{ name = 'crouch', from = 'landing', to = 'crouching' },
			{ name = 'crouch', from = 'teching', to = 'crouching' },
			{ name = 'crouch', from = 'hitstunned', to = 'crouching' },
			{ name = 'crouch', from = 'clashing', to = 'crouching' },
			
			-- { name = 'crouch', from = 'foxtrot', to = 'crouching' },
		},
		callbacks = {
			onleavehitstunned = function(self, event, from, to)
				-- Keep track of amounts of hits we've taken before reaching a state other than hitstunned
				if to == "teching" then
					data.states.hitstunned.vals.hit_counter = 0
					data.states.hitstunned.vals.knockdown = false
					return true
				end
				
				if to ~= "hitstunned" then
					if (
						(data.inputs.do_jump()) and 
						(not data.collision.d and not data.collision:check_close_to_ground(vmath.vector3(go.get_world_position())))
						) then
						data.states.hitstunned.vals.hit_counter = 0
						data.fsm:tech()
						return false
					end
					data.states.hitstunned.vals.hit_counter = 0
				else
					data.states.hitstunned.vals.hit_counter = data.states.hitstunned.vals.hit_counter + 1
				end
				
				if data.states.hitstunned.vals.knockdown then 
					if to == "knockdown" then
						data.states.hitstunned.vals.knockdown = false
						return true
					end
					return false
				end

				if data.fsm.state_duration < 1 or from == "hitstunned" then
					return true
				else
					return false
				end
			end,
			onleaveteching = function(self, event, from, to)
				if data.fsm.state_duration < 1 then
					data.states.teching.vals.teched = false
					return true
				else
					return false
				end
			end,
			onleaveclashing = function(self, event, from, to)
				if (to == 'foxtrot' or to == 'jumping') and data.fsm.state_duration > 16 then
					return false
				else
					return true
				end
			end,
			onleaveattacking = function(self, event, from, to)
				local cursor = go.get("#spr", "cursor")
				local sprite_anim = go.get("#spr", "animation")

				-- if (to == "airdashing" or to == "foxtrot") then
				-- 	if hitboxman.state == 2 then
				-- 		return true
				-- 	else
				-- 		return false
				-- 	end
				-- end

				if cursor ~= 1.0 and ((to ~= 'clashing' and to ~= 'hitstunned') and not (data.states.attacking.vals.air and to ~= "falling")) then
					return false
				end

				if to == "attacking" and not (data.hitboxman.can_extend and data.hitboxes[sprite_anim]).extension then
					return false
				end

				return true
			end,
			onleaveknockdown = function(self, event, from, to)
				if data.fsm.state_duration < 1 then
					return true
				else
					return false
				end
			end,
			onstatechange = function(self, event, from, to) 
				data.states[from]:exit(to)
				data.states[to]:enter(from)
			end,
		}
	});

	-- Variable for storing time since the state began, in case the particular state ends on a timer or has time-sensitive actions
	data.fsm.state_duration = 0
end

function controller.new(_data)
	assert(_data)
	assert(_data.hitboxes)
	assert(_data.inputs)
	assert(_data.states_table)
	assert(_data.collection)
	
	local data = {
		hitboxes = _data.hitboxes,
		inputs = _data.inputs,
		collection = _data.collection
	}
	
	--_pre-initialize our controller components
	-- Collision handles raycasts + pushing away actor object position from walls and floors.
	-- Movement handles speed vector calc operations.
	-- FSM is our state machine,
	-- and 'states' defines a table in which we have callbacks for state enter, exit and update, as well as related values.
	
	-- import libraries and object types to use
	
	
	-- Initialize collision/movement objects
	data.collision = require('main.actor.collision.collision')(physics.get_shape("#bounding_box", "Box"), _data.col_group)
	data.movement = require('main.actor.movement.movement')({collision=data.collision,inputs=data.inputs})

	if _data.movement ~= nil then
		for k, v in pairs(_data.movement) do data.movement[k] = v end -- overwrite movement table with data passed to controller
	end

	data.hitboxman = require('main.actor.hitboxes.hitbox_manager')({hitboxes=data.hitboxes, movement=data.movement, spr_url=spr_url})

	if _data.frame_vars ~= nil then
		for k, v in pairs(_data.frame_vars) do data.hitboxman[k] = v end -- overwrite hitbox manager table with data passed to controller
	end
	
	init_states(data)
	
	data.states = StatesTables.get(data, _data.states_table)
	
	local self = setmetatable(data, controller)
	self._index = self

	msg.post("/level#level", "controller_init")
	-- set properties
	go.set(msg.url(), "weight", self.movement.weight)
	return self
end

-- Auxiliary function that automatically changes states if the incoming state has an event defined and the associated input has been issued.
function controller:check_inputs()
	
	if (self.inputs.down() and
		(self.fsm.state_duration == 0 or self.fsm.current == "foxtrot") and
		self.collision.contact.d and 
		self.fsm.events.crouch.map[self.fsm.current] and self.fsm.events.crouch.map[self.fsm.current] == 'crouching') then
		self.fsm:crouch()
	elseif (self.movement.move_dir.x ~= 0 and 
		self.fsm.state_duration == 0 and 
		self.collision.contact.d and 
		self.fsm.events.walk.map[self.fsm.current] and self.fsm.events.walk.map[self.fsm.current] == 'walking') then
		self.fsm:walk()
	end
	
	if self.inputs.do_jump() and self.collision.contact.d and self.fsm.events.jump.map[self.fsm.current] and self.fsm.events.jump.map[self.fsm.current] == 'jumping' then
		self.fsm:jump()
	end
	
	-- if self.inputs.do_attack() and self.fsm.events.attack.map[self.fsm.current] and self.fsm.events.attack.map[self.fsm.current] == 'attacking' then
	-- 	self.fsm:attack()
	-- end
	-- if self.inputs.do_foxtrot() and self.collision.contact.d and self.fsm.events.step.map[self.fsm.current] and self.fsm.events.step.map[self.fsm.current] == 'foxtrot' then
	-- 	self.fsm:step()
	-- end
	-- if self.inputs.do_airdash() and self.fsm.state_duration == 0 and self.fsm.can_airdash and not self.collision.contact.d 
	-- and self.fsm.events.airdash.map[self.fsm.current] and self.fsm.events.airdash.map[self.fsm.current] == 'airdashing' then
	-- 	self.fsm:airdash()
	-- end
end

function controller:update(dt, debug)
	-- input_parser.update_inputs()
	self.movement:update_move_dir(self.inputs)

	self.states[self.fsm.current]:update(dt)
	self:check_inputs()
	if self.fsm.state_duration > 0 then
		self.fsm.state_duration = self.fsm.state_duration - 1
	end
	go.set(msg.url(), "speed", self.movement.speed)
	go.set(msg.url(), "contact_l", self.collision.contact.l)
	go.set(msg.url(), "contact_r", self.collision.contact.r)
	go.set(msg.url(), "contact_u", self.collision.contact.u)
	go.set(msg.url(), "contact_d", self.collision.contact.d)
	go.set(msg.url(), "push", self.collision.push)
	if self.collision.slope_down then go.set(msg.url(), "slope_down", self.collision.slope_down) end
	
	self.collision:update_position(dt, self.movement, debug)
	self.hitboxman:update()

	if self.movement.push ~= vmath.vector3() then
		self.movement.push = vmath.vector3()
	end
end
-- 
-- function on_input(self, action_id, action)
-- 	input_parser.receive_input(action_id, action)
-- end

function controller:on_message(message_id, message, sender)
	if message_id == hash("received_hitcollision") and not self.hitboxman.ignore_hitcollision and self.fsm.current == "attacking" then
		self.states.attacking.vals.collision_knockback = message.knockback
		self.states.attacking.vals.collision_angle = message.angle
		self.states.attacking.vals.collision_flip = message.flip
		self.hitboxman.ignore_hitcollision = true
	end

	if message_id == hash("received_clash") and not self.hitboxman.ignore_senders[message.hitbox_parent.path] then
		self.hitboxman.ignore_senders[message.hitbox_parent.path] = true
		self.states.clashing.vals.knockback = (20 + math.max(0, message.other_knockback - message.self_knockback))*4
		self.states.clashing.vals.flip = message.flip
		self.fsm:clash()
	end

	if message_id == hash("received_hitbox") and not self.hitboxman.ignore_senders[message.hitbox_parent.path] then
		self.hitboxman.ignore_senders[message.hitbox_parent.path] = true
		go.set(msg.url(), "health", go.get(msg.url(),"health") - message.damage)
		
		self.states.hitstunned.vals.knockback = message.knockback
		self.states.hitstunned.vals.hitstun = message.hitstun
		self.states.hitstunned.vals.angle = message.angle
		self.states.hitstunned.vals.knockdown = message.knockdown
		self.fsm:hitstun()
	end
	
	if message_id == hash("controller_reset_sender_ignore") and message.controller and self.hitboxman.ignore_senders[message.controller] then
		print("resetting")
		self.hitboxman.ignore_senders[message.controller] = nil
	end

	if	message_id == hash("collision_push") and 
		self.collision.contact.d and 
		self.fsm.current ~= "foxtrot" and
		self.fsm.current ~= "teching" then
		self.movement:set_push(vmath.vector3(self.movement.pushed_speed.x * message.direction * (1-message.fraction), 0, 0))
	end

	if message_id == hash("is_falling") and not self.collision.contact.d and self.fsm.current ~= "jumping" 
		and self.fsm.current ~= "falling" and self.fsm.current ~= "airdashing" and self.fsm.current ~= "hitstunned" then
		self.fsm:fall()
	end
end

return controller