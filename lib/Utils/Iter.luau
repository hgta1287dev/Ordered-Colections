local Iter = {}
Iter.__index = Iter

export type Iter<T> = {
	next: () -> T?,
	map: (self: Iter<T>, fn: (T) -> any) -> any, --! return Type<U>
	filter: (self: Iter<T>, fn: (T) -> boolean) -> Iter<T>,
	take: (self: Iter<T>, n: number) -> Iter<T>,
	skip: (self: Iter<T>, n: number) -> Iter<T>,

	forEach: (self: Iter<T>, fn: (T) -> ()) -> (),
	toArray: (self: Iter<T>) -> { T },

	find: (self: Iter<T>, fn: (T) -> boolean) -> T?,
	some: (self: Iter<T>, fn: (T) -> boolean) -> boolean,
	every: (self: Iter<T>, fn: (T) -> boolean) -> boolean,
}

-- * RAW
function Iter.fromLinked(head, reverse)
	local node = head

	return function()
		if not node then
			return nil
		end

		local current = node
		node = if reverse then current.prev else current.next

		return current
	end
end

function Iter.values<T>(head: any, reverse: boolean?): () -> T?
	local nextNode = Iter.fromLinked(head, reverse)

	return function()
		local node = nextNode()
		return node and node.value or nil
	end
end

function Iter.keyValues<K, V>(head: any, reverse: boolean?): () -> (K?, V?)
	local nextNode = Iter.fromLinked(head, reverse)

	return function()
		local node = nextNode()
		if not node then
			return nil, nil
		end
		return node.key, node.value
	end
end

-- * CONSTRUCTOR
function Iter.new(nextFn)
	return setmetatable({
		next = nextFn,
	}, Iter)
end

-- * TRANSFORMS
function Iter:map(fn)
	return Iter.new(function()
		local v = self.next()
		if v == nil then
			return nil
		end
		return fn(v)
	end)
end

function Iter:filter(fn)
	return Iter.new(function()
		while true do
			local v = self.next()
			if v == nil then
				return nil
			end
			if fn(v) then
				return v
			end
		end
	end)
end

function Iter:take(n)
	local count = 0
	return Iter.new(function()
		if count >= n then
			return nil
		end
		local v = self.next()
		if v == nil then
			return nil
		end
		count += 1
		return v
	end)
end

function Iter:skip(n)
	local skipped = false
	return Iter.new(function()
		if not skipped then
			for _ = 1, n do
				if self.next() == nil then
					return nil
				end
			end
			skipped = true
		end
		return self.next()
	end)
end

-- * TERMINALS
function Iter:forEach(fn)
	while true do
		local v = self.next()
		if v == nil then
			break
		end
		fn(v)
	end
end

function Iter:toArray()
	local result = {}
	self:forEach(function(v)
		table.insert(result, v)
	end)
	return result
end

function Iter:find(fn)
	while true do
		local v = self.next()
		if v == nil then
			return nil
		end
		if fn(v) then
			return v
		end
	end
end

function Iter:some(fn)
	return self:find(fn) ~= nil
end

function Iter:every(fn)
	while true do
		local v = self.next()
		if v == nil then
			return true
		end
		if not fn(v) then
			return false
		end
	end
end

return Iter
