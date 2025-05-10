local StatesTables = {}

local function concat_tables(table1, table2)
	for k,v in pairs(table2) do table1[k] = v end
	return table1
end


function StatesTables.get(controller, name)

	local tables = {
		BaseActor =
		{
			idle = require('main.actor.states.generic.idle')(controller.movement, controller.collision, controller.inputs, controller.fsm),
			hitstunned = require('main.actor.states.generic.hitstunned')(controller.movement, controller.collision, controller.inputs, controller.fsm),
			falling = require('main.actor.states.generic.falling')(controller.movement, controller.collision, controller.inputs, controller.fsm),
			knockdown = require('main.actor.states.generic.knockdown')(controller.movement, controller.collision, controller.inputs, controller.fsm, controller.hitboxman),
			teching = require('main.actor.states.generic.teching')(controller.movement, controller.collision, controller.inputs, controller.fsm, controller.hitboxman),
			landing = require('main.actor.states.generic.landing')(controller.movement, controller.collision, controller.inputs, controller.fsm, controller.hitboxman),
		}
	}

	tables.GenericActor = concat_tables({
		walking = require('main.actor.states.generic.walking')(controller.movement, controller.collision, controller.inputs, controller.fsm),
		crouching = require('main.actor.states.generic.crouching')(controller.movement, controller.collision, controller.inputs, controller.fsm),
		jumping= require('main.actor.states.generic.jumping')(controller.movement, controller.collision, controller.inputs, controller.fsm),
		attacking = require('main.actor.states.generic.attacking')(controller.movement, controller.collision, controller.inputs, controller.fsm, controller.hitboxman),
		clashing = require('main.actor.states.generic.clashing')(controller.movement, controller.collision, controller.inputs, controller.fsm),
	}, tables.BaseActor)
	
	tables.PlayerActor = concat_tables({
		foxtrot = require('main.actor.states.player.foxtrot')(controller.movement, controller.collision, controller.inputs, controller.fsm),
		airdashing = require('main.actor.states.player.airdashing')(controller.movement, controller.collision, controller.inputs, controller.fsm),
	}, tables.GenericActor)
	
	return tables[name]
end

return StatesTables