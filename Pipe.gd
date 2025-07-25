class_name Pipe

var couplings: Array[Pipe]
var priority: int = 0
var base: Variant:
	set(v):
		base = v
		_dirty = false
var value: Variant:
	get:
		if _dirty or not value:
			value = _fill(base)
			_dirty = false
		return value

var _dirty: bool = false

func _init(_base: Variant) -> void:
	base = _base
	flush()

func _fill(start_value: Variant) -> Variant:
	couplings.sort_custom(func(a: Pipe, b: Pipe) -> bool: return a.priority < b.priority)
	for i in range(couplings.size()):
		var c: Pipe = couplings[i]
		if c.couplings.size():
			var b: Variant = c.base
			var group: Variant = c._fill(c.base)
			c.base = group
			start_value = c.effect.call(start_value)
			c.base = b
		else:
			start_value = c.effect.call(start_value)
	return start_value

func effect(_value: Variant) -> Variant: return _value

func flush() -> void:
	for c in couplings:
		c.free()
	couplings = []
	_dirty = true

func add(coupling: Pipe) -> bool:
	if couplings.find(coupling) == -1: return false
	couplings.push_back(coupling)
	return true

func remove(coupling: Pipe) -> bool:
	var index := couplings.find(coupling)
	if index != -1:
		couplings.remove_at(index)
	return index != -1
