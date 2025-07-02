require('bit')

local DEFAULT_DURATION = 5
local DEFAULT_BUFFER = 3

local input_mask = require('main.actor.states.inputs.bitmasks')

local make_input = function (bitmask, release)
	if release == nil then release = false end
	
	return {
		input = bitmask,
		release = release
	}
end

local sequences = {}

local all_dir = bit.bor(input_mask[hash("moveUp")], input_mask[hash("moveDown")],input_mask[hash("moveLeft")],input_mask[hash("moveRight")])

sequences.make = function (name, seq, dur, buf)
	return {
		name = name,
		seq = seq,
		dur = dur or DEFAULT_DURATION,
		buf = buf or DEFAULT_BUFFER
	}
end

sequences.make_tap = function (name, bitmask)
	return sequences.make(
		name,
		{
			make_input(bitmask),
			make_input(bitmask, true)
		},
		7
	)
end

sequences.tap_left = sequences.make_tap("tap_left", input_mask[hash("moveLeft")])
sequences.tap_up = sequences.make_tap("tap_up", input_mask[hash("moveUp")])
sequences.tap_down = sequences.make_tap("tap_down", input_mask[hash("moveDown")])
sequences.tap_right = sequences.make_tap("tap_right", input_mask[hash("moveRight")])

sequences.attack_left = sequences.make(
	"attack_left",
	{make_input(bit.bor(input_mask[hash("attack")], input_mask[hash("moveLeft")]))}
)

sequences.attack_up = sequences.make(
	"attack_up",
	{make_input(bit.bor(input_mask[hash("attack")], input_mask[hash("moveUp")]))}
)

sequences.attack_down = sequences.make(
	"attack_down",
	{make_input(bit.bor(input_mask[hash("attack")], input_mask[hash("moveDown")]))}
)

sequences.attack_right = sequences.make(
	"attack_right",
	{make_input(bit.bor(input_mask[hash("attack")], input_mask[hash("moveRight")]))}
)

sequences.attack_n = sequences.make(
	"attack_n",
	{make_input(input_mask[hash("attack")])}
)

sequences.jump = sequences.make(
	"jump",
	{make_input(input_mask[hash("jump")])}
)

local commands = {
	elena = {
		sequences.tap_left,
		sequences.tap_right,
		sequences.tap_down,
		sequences.tap_up,
		sequences.attack_left,
		sequences.attack_right,
		sequences.attack_down,
		sequences.attack_up,
		sequences.attack_n,
		sequences.jump
	}
}

return commands