require('bit')

local M = {};

local input_mask = {}
input_mask[hash("moveUp")] = bit.lshift(1, 0)
input_mask[hash("moveDown")] = bit.lshift(1, 1)
input_mask[hash("moveLeft")] = bit.lshift(1, 2)
input_mask[hash("moveRight")] = bit.lshift(1, 3)
input_mask[hash("jump")] = bit.lshift(1, 4)
input_mask[hash("attack")] = bit.lshift(1, 5)
input_mask[hash("furia")] = bit.lshift(1, 6)

M.input_hist = {
	{
		buttons = 0,
		frames = 0,
		used = false,
	}
}

local input_hist_max = 20 -- indexes start at 1 'v'

local function check_button_array(input) 
	local mask = input
	if type(mask) == "table" then
		local mask_table = {}
		for _, value in ipairs(input) do
			mask_table[_] = input_mask[value]
		end
		mask = bit.bor(unpack(mask_table))
	else
		mask = input_mask[input]
	end
	return mask
end

function M.update_inputs()
	M.input_hist[#M.input_hist].frames = M.input_hist[#M.input_hist].frames + 1
	if #M.input_hist > 1 and M.input_hist[#M.input_hist-1].frames == 0 then -- remove ghost inputs from history
		table.remove(M.input_hist, #M.input_hist-1)
	end
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

function M.last_input(inputs)
	if inputs then 
		local mask = check_button_array(inputs)
		for i = #M.input_hist, 1, -1 do
			local input = M.input_hist[i];
			if (bit.band(input.buttons, mask) > 0) then
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
	else
		return false
	end
end

function M.check_length(input, length)
	local mask = check_button_array(input)

	-- can't be held if the last input wasn't this button
	if (bit.band(M.last_input().buttons, mask) == 0) then return false end

	local input_duration = 0
	
	for i = #M.input_hist, 1, -1 do
		local input = M.input_hist[i];
		if (bit.band(input.buttons, mask)) > 0 then
			input_duration = input_duration + input.frames
		end
		if input_duration > length then
			return false
		end
		if input_duration > 0 and (bit.band(input.buttons, mask)) == 0 then
			break
		end
	end
	
	if input_duration > 0 and input_duration <= length then
		return true
	else
		return false
	end
end

function M.check_step(buttons, buffer)
	if buffer == nil then buffer = 7 end
	
	local mask = check_button_array(buttons)
	local input_duration = 0;
	-- can't be a tap if the last input wasn't a release
	if (bit.band(M.last_input().buttons, mask) > 0) then return false end

	for i = #M.input_hist, 1, -1 do
		local input = M.input_hist[i];
		input_duration = input_duration + input.frames
		
		if (bit.band(input.buttons, mask) > 0) then
			if input_duration > 0 and input_duration < buffer then
				return true
			end
		end
		
		if input_duration > buffer then break end
	end

	return false
end

function M.filter_input(input, button_list) -- returns first found button from the buttons array in the input
	for _, button in ipairs(button_list) do
		if bit.band(input.buttons, input_mask[button]) > 0 then
			return button
		end
	end
	return nil
end

return M