local class = require('main.utils.class')

local state = class.new_class({})

function state.new(_data) 
	assert(_data)
	local data = {
		name = _data.name or "null",
		enter = _data.enter or class.empty_fn(),
		exit = _data.exit or class.empty_fn(),
		update = _data.update or class.empty_fn(),
		vals = _data.vals or {},
	}
	local self = setmetatable(data, state)
	self._index = self
	return self
end

return state