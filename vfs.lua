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
	t.readonly = self.readonly
	t.nowrite = self.nowrite
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
		self.readonly = t.readonly
		self.nowrite = t.nowrite
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
	if self.opens[id] and self:is_space(string.len(str)) and (not self.readonly) then
		local old = self.fs[self.opens[id].fname]
		if old then
			local old = string.sub(old, 0, self.opens[id].pos)
			if old and old ~= "" and self.opens[id].pos ~= 0 then
				self.fs[self.opens[id].fname] = old.."\n"..str
			else
				self.fs[self.opens[id].fname] = str
			end
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

function vfs:close(id)
	self.opens[id] = nil
end

function vfs:close_all()
	self.opens = {}
end

function vfs:list(print)
	local list = ""
	local line = 0
	for name, _ in pairs(self.fs) do
		list = list.." "..name
		line = line + 1
		if line > 4 then
			print(list)
			list = ""
			line = 0
		end
	end
	print(list)
end

function vfs:cp(f1, f2)
	if self.fs[f1] and (not self.readonly) then
		if self:is_space(string.len(self.fs[f1])) then
			self.fs[f2] = self.fs[f1]
		end
	end
end

function vfs:mv(f1, f2)
	if self.fs[f1] and (not self.readonly) then
		self.fs[f2] = self.fs[f1]
		self.fs[f1] = nil
	end
end

function vfs:cat(f, print)
	local c = self.fs[f]
	if not c then
		return
	end
	local line = c:find("\n")
	if not line then
		print(c)
	end
	while line do
		print(string.sub(c, 0, line-1))
		c = string.sub(c, line+1, -1)	
		line = c:find("\n")
	end
	print(c)
end

function vfs:rm(f)
	if not self.readonly then
		self.fs[f] = nil
	end
end

function vfs:format()
	if not self.readonly then
		self.fs = {}
		self.opens = {}
	end
end

function vfs:save(f, str)
	if not self.readonly then
		self.fs[f] = str
	end
end

function vfs:load(f)
	return self.fs[f]
end

function vfs:set_readonly()
	self.readonly = true
end

function vfs:set_readwrite()
	if not self.nowrite then
		self.readonly = nil
	end
end
return vfs
