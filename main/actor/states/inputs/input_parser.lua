require('bit') -- we use bitmask for the inputs
local t = require('main.utils.table')

local DEFAULT_PLAYER = "elena" 

local commands = require('main.actor.states.inputs.commands') -- get commands we'll be using for the character this module is attached to
local input_mask = require('main.actor.states.inputs.bitmasks') -- get the input masks we'll be using

local M = {};

M.player = DEFAULT_PLAYER -- if i ever add more characters, this will have to be changed so you can set input_parser's player when calling it

M.input_hist = {
	-- Input history local to the instance of the input parser we're using.
	-- Saves a cycling log of what buttons were pressed and for how long.
	{
		buttons = 0,
		frames = 0
	}
}

M.buffer = {
	-- We save a buffer of commands that have been detected in the input history.
	-- "buf" describes a duration (in frames) which is ticked down and removed from this buffer
	-- once it hits 0.
	
	-- {
	--_	name = "",
	--_ buf = "",
	--_} 
} 

local input_hist_max = 20 -- indexes start at 1 'v'

local function check_button_array(input) 
	-- used in functions from this class when we pass a table of hashes
	
	-- this makes it so the inputs are tested all at once instead of separately,
	-- by creating an OR mask that encompasses all the inputs in that table

	local mask = input
	if type(mask) == "table" then
		local mask_table = {}
		for _, value in ipairs(input) do
			mask_table[_] = input_mask[value]
		end
		mask = bit.bor(unpack(mask_table))
	else
		-- failsafe so non-tables don't fail
		mask = input_mask[input]
	end

	return mask
end

function M.update_buffer()
	-- Go through the buffer and tick the "buf" value down each frame.
	-- Remove them if the "buf" value goes below 1.
	
	for idx, v in ipairs(M.buffer) do
		M.buffer[idx].buf = M.buffer[idx].buf - 1
		if M.buffer[idx].buf < 1 then 
			table.remove(M.buffer, idx) 
		end
	end	
end

function M.check_commands()
	-- Check the commands detailed in the commands.lua file for the pertinent player.
	local local_cmds = {}

	local frames = 0
	-- Get max duration of commands when looping through the list, so we can break
	-- out of the command-checking loop easier later.
	local max_dur = 0
	-- We save a list of the indexes we just looped through,
	-- to set the "used" field on them in case we do find a command.

	-- This is to avoid the same input triggering multiple commands at once.
	local input_hist_idx = {}
	
	-- First, we create a local copy of all commands with some extra variables.
	for key, command in next, commands[M.player] do
		local_cmds[command.name] = t.shallowcopy(command)
		-- 'reading' decides whenever this command will be checked during the loop or not. 
		local_cmds[command.name].reading = true
		-- 'active' determines whenever the command was found or not.
		local_cmds[command.name].active = false
		-- We save an index of the sequence to check for matches more efficiently.
		local_cmds[command.name].seq_idx = #local_cmds[command.name].seq

		if command.dur > max_dur then max_dur = command.dur end
		
		-- Check if the command is already in our buffer: if so, we won't be checking for it this time.
		for buf_idx=1, #M.buffer do
			if M.buffer[buf_idx].name == command.name then
				local_cmds[command.name].reading = false
			end
		end
	end



	for hist = #M.input_hist, 1, -1 do
		-- Break out if no commands have a duration higher than our current frame count.
		if frames > max_dur then break end

		input_hist_idx[#input_hist_idx + 1] = hist

		-- Add current input's frames to our frame count.
		frames = frames + M.input_hist[hist].frames
		local input = M.input_hist[hist].buttons

		if not M.input_hist[hist].used then 
			for key, command in next, local_cmds do
				if command.reading and frames <= command.dur then 				
					local bitmask = command.seq[command.seq_idx].input
					local release = command.seq[command.seq_idx].release

					if (((bit.band(bitmask, input)) == bitmask and not release) or 
					((bit.band(bitmask, input)) == 0 and release)) then
						-- If, after looping through all the elements in the sequence, we find a match at the
						-- first index, that means we have found a match. So, set it to active and stop checking
						-- for it.
						if command.seq_idx == 1 then
							command.active = true
							command.reading = false
						else
						-- Continue looking through the sequence if a match was found.
							command.seq_idx = command.seq_idx - 1
						end
					elseif command.seq_idx == #command.seq then 
						-- To make the command valid, the most recent input has contain the last bitmask in the sequence.
						-- So the "reading" field is set to "false" if this isn't the case. We won't check for it anymore.
						command.reading = false
					end
				end
			end
		end
	end

	for key, command in next, local_cmds do
		if command.active then
			-- Set last element of buffer to the command. We only need a couple of fields.
			M.buffer[#M.buffer+1] = {
				name = command.name,
				buf = command.buf
			}
			-- Make sure to set the "used" field of the inputs we looped through, so we don't get duplicate commands
			-- when looping through our input history later. 
			for idx = 1, #input_hist_idx do
				M.input_hist[input_hist_idx[idx]].used = true
			end
			break
		end
	end
end

function M.clean_socd()
	-- Check for simulataneous opposite cardinal directions (so, up + down or left + right).
	-- Simple bitmask check.
	if bit.band(M.input_hist[#M.input_hist].buttons, 12) == 12 or bit.band(M.input_hist[#M.input_hist].buttons, 3) == 3 then
		-- Because we have tap inputs, we set whatever inputs happened beforehand as "used" to avoid
		-- SOCD inputs triggering instant foxtrots and airdashes.

		-- You wouldn't do this if this was a fighting game. Probably.
		M.input_hist[#M.input_hist].used = true
		if M.input_hist[#M.input_hist-1] then M.input_hist[#M.input_hist-1].used = true end
	end
end

function M.update_inputs()
	-- Update frame count for the last input in the history.
	M.input_hist[#M.input_hist].frames = M.input_hist[#M.input_hist].frames + 1
	if #M.input_hist > 1 and M.input_hist[#M.input_hist-1].frames == 0 then -- remove ghost inputs from history
		table.remove(M.input_hist, #M.input_hist-1)
	end

	M.clean_socd()
	
	M.update_buffer()
		
	M.check_commands()
end

function M.receive_input(action_id, action)
	local input

	if action_id == nil or input_mask[action_id] == nil then return end
	if not action.pressed and not action.released then return end

	input = {
		buttons = M.input_hist[#M.input_hist].buttons,
		frames = 0,
		used = false
	}

	if #M.input_hist == input_hist_max then
		table.remove(M.input_hist, 1)
	end

	if action.pressed then
		input.buttons = bit.bor(input.buttons, input_mask[action_id])
	elseif action.released then
		input.buttons = bit.band(input.buttons, bit.bnot(input_mask[action_id]))
	end
	
	M.input_hist[#M.input_hist+1] = input;
end

function M.last_input(input)
	-- if input argument is passed 
	if input then 
		local mask = check_button_array(input)
		for i = #M.input_hist, 1, -1 do
			local found_input = M.input_hist[i];
			if (bit.band(found_input.buttons, mask) > 0) then
				return M.input_hist[i]
			end
		end
	else
		return M.input_hist[#M.input_hist]
	end
	return nil
end

function M.check_input(input)
	local mask = check_button_array(input)
 
	if bit.band(M.input_hist[#M.input_hist].buttons, mask) > 0 then
		return true
	end	
		
	return false
end

-- Deprecated (now using commands and the "used" field in inputs)

-- function M.check_length(input, length)
-- 	local mask = check_button_array(input)
-- 
-- 	-- can't be held if the last input wasn't this button
-- 	if (bit.band(M.last_input().buttons, mask) == 0) then return false end
-- 
-- 	local input_duration = 0
-- 	
-- 	for i = #M.input_hist, 1, -1 do
-- 		local input = M.input_hist[i];
-- 		if (bit.band(input.buttons, mask)) > 0 then
-- 			input_duration = input_duration + input.frames
-- 		end
-- 		if input_duration > length then
-- 			return false
-- 		end
-- 		if input_duration > 0 and (bit.band(input.buttons, mask)) == 0 then
-- 			break
-- 		end
-- 	end
-- 	
-- 	if input_duration > 0 and input_duration <= length then
-- 		return true
-- 	else
-- 		return false
-- 	end
-- end

-- function M.check_step(buttons, buffer)
-- 	if buffer == nil then buffer = 7 end
-- 	
-- 	local mask = check_button_array(buttons)
-- 	local input_duration = 0;
-- 	-- can't be a tap if the last input wasn't a release
-- 	if (bit.band(M.last_input().buttons, mask) > 0) then return false end
-- 
-- 	for i = #M.input_hist, 1, -1 do
-- 		local input = M.input_hist[i];
-- 		input_duration = input_duration + input.frames
-- 		
-- 		if (bit.band(input.buttons, mask) > 0) then
-- 			if input_duration > 0 and input_duration < buffer then
-- 				return true
-- 			end
-- 		end
-- 		
-- 		if input_duration > buffer then break end
-- 	end
-- 
-- 	return false
-- end

function M.filter_input(input, button_list) -- returns first found button from the buttons array in the input
	for _, button in ipairs(button_list) do
		if bit.band(input.buttons, input_mask[button]) > 0 then
			return button
		end
	end
	return nil
end

function M.dir_input_vector() -- returns last input as a normalized direction vector
	local input = M.last_input()
	local dir = vmath.vector3()
	
	if input == nil then return dir end

	-- check if last input has directions, if not then return
	local mask = check_button_array({hash("moveLeft"),hash("moveRight"),hash("moveUp"),hash("moveDown")})
	if bit.band(input.buttons, mask) <= 0 then
		return dir
	end

	-- positive directions (right, up) - negative directions (left, down) to get the normalized dir for both axis
	dir.x = bit.band(input.buttons, input_mask[hash("moveRight")]) - bit.band(input.buttons, input_mask[hash("moveLeft")])
	dir.y = bit.band(input.buttons, input_mask[hash("moveUp")]) - bit.band(input.buttons, input_mask[hash("moveDown")])

	-- normalize dirs so their sum is 1
	dir = vmath.normalize(dir)

	return dir
end
return M