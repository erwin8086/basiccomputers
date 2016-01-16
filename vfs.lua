local vfs = {}

function vfs:new(n)
	n = n or {}
	setmetatable(n, self)
	self.__index = self
	n.fs = {}
	n.opens = {}
	n.size = 20
	return n
end

function vfs:to_table()
	local t = {}
	t.opens = self.opens
	t.fs = self.fs
	t.size = self.size
	return t
end

function vfs:from_table(t)
	if t then
		if t.opens then
			self.opens = t.opens
		end
		if t.fs then
			self.fs = t.fs
		end
		if t.size then
			self.size = t.size
		end
	end
end

function vfs:open(fname, id)
	self.opens[id] = { fname=fname, pos=0 }
end

function vfs:read(id)
	if self.opens[id] then
		local content = string.sub(self.fs[self.opens[id].fname], self.opens[id].pos, -1)
		local line = content:find("\n")
		if line then
			local read = string.sub(content, 0, line-1)
			self.opens[id].pos = self.opens[id].pos + line + 1
			return read
		else
			self.opens[id].pos = self.opens[id].pos + string.len(content)
			return content
		end
	else
		return ""
	end
end

function vfs:write(id, str)
	if self.opens[id] and self:is_space(string.len(str)) then
		local old = self.fs[self.opens[id].fname]
		if old then
			local old = string.sub(old, 0, self.opens[id].pos)
			self.fs[self.opens[id].fname] = old.."\n"..str
		else
			self.fs[self.opens[id].fname] = str
		end
		self.opens[id].pos = self.opens[id].pos + string.len(str) + 1
	end
end

function vfs:get_size()
	local size = 0
	for _, str in pairs(self.fs) do
		size = size + string.len(str)
	end
	return size
end

function vfs:set_size(size)
	self.size = size
end

function vfs:is_space(size)
	if (self:get_size() + size) <= self.size then
		return true
	else
		return false
	end
end
return vfs
