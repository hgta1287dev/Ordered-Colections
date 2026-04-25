local Map = require(script.Collections.Map)
local PriorityQueue = require(script.Collections.PriorityQueue)
local Queue = require(script.Collections.Queue)
local Set = require(script.Collections.Set)
local Stack = require(script.Collections.Stack)

export type Set<T> = Set.Set<T>
export type Map<K, V> = Map.Map<K, V>
export type Queue<T> = Queue.Queue<T>
export type PriorityQueue<T> = PriorityQueue.PriorityQueue<T>
export type Stack<T> = Stack.Stack<T>

local Collections = {
	Set = Set,
	Map = Map,
	Queue = Queue,
	PriorityQueue = PriorityQueue,
	Stack = Stack,
}

return Collections
