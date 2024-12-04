class_name Pipe extends Node

var priority: int = 0
var base: Variant:
	set(v):
		base = v
		_dirty = false
var value:
	get:
		if _dirty or not value:
			value = _fill(base)
			_dirty = false
		return value

var _dirty: bool = false

func _init(_base: Variant) -> void:
	base = _base
	flush()

func _fill(start_value):
	var couplings = get_children().filter(func(c: Node): return c is Pipe)
	couplings.sort_custom(func(a: Pipe, b: Pipe): return a.priority < b.priority)
	for i in range(couplings.size()):
		var c: Pipe = couplings[i]
		if c.get_children():
			var base = c.base
			var group = c._fill(c.base)
			c.base = group
			start_value = c.pipe.call(start_value)
			c.base = base
		else:
			start_value = c.pipe.call(start_value)
	return start_value

func effect(value: Variant) -> Variant: return value

func flush() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()
	_dirty = true

func add(coupling: Pipe) -> bool:
	if get_children().has(coupling): return false
	if coupling.is_inside_tree(): coupling = coupling.duplicate()
	add_child(coupling)
	return true

func remove(coupling_name: String) -> bool:
	var node = find_child(coupling_name, false)
	if node: remove_child(node)
	return !!node
