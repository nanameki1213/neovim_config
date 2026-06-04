-- Stub for missing vim.deprecated.health module (nvim 0.12.2 bug)
return setmetatable({}, {
	__index = function()
		return function() end
	end,
})
