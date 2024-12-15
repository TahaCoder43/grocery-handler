class_name Animator extends Node

@export var to_color: Color = Color(0, 0, 0, 0.5)
@export var duration: float = 0.3 ## in seconds
@export var transition_type: Tween.TransitionType
@export var themes_to_animate: Array[String] = ["panel"]

var targets: Array[StyleBox]
var target_node: Control
var from_colors: Array[Color]

func _ready() -> void:
	setup()
	connect_signals()
	
func setup() -> void:
	target_node = get_parent()
	var original_styleboxes: Array[StyleBox]
	original_styleboxes.assign(themes_to_animate.map(
		func(theme) -> StyleBox:
			return target_node.get_theme_stylebox(theme)
	))
	# styleboxes are duplicated, cause by default all instances of 
	# a node or a scene share styleboxes
	var unique_styleboxes: Array[StyleBox]
	unique_styleboxes.assign(original_styleboxes.map(
		func(stylebox): return stylebox.duplicate())
	)
	targets = unique_styleboxes
	for i in range(themes_to_animate.size()):
		var theme_to_animate = themes_to_animate[i]
		var unique_stylebox = unique_styleboxes[i]
		target_node.remove_theme_stylebox_override(theme_to_animate)
		target_node.add_theme_stylebox_override(theme_to_animate, unique_stylebox)
	from_colors.assign(targets.map(func(target): return target.bg_color))
	print("from_color ", from_colors)

func connect_signals() -> void:
	target_node.mouse_entered.connect(on_mouseenter_parent)
	target_node.mouse_exited.connect(on_mouseexit_parent)

func on_mouseenter_parent() -> void:
	for i in range(targets.size()):
		var target = targets[i]
		var from_color = from_colors[i]
		add_tween(target, "bg_color", to_color, duration, from_color)
 
func on_mouseexit_parent() -> void:
	for i in range(targets.size()):
		var target = targets[i]
		var from_color = from_colors[i]
		add_tween(target, "bg_color", from_color, duration, from_color)	
	
func add_tween(target_stylebox: StyleBox, property: String, value, duration: float, from_color: Color) -> void:
	var tree = get_tree()
	if tree == null:
		target_stylebox.bg_color = from_color
		return
	var tween = tree.create_tween()
	tween.tween_property(target_stylebox, property, value, duration).set_trans(transition_type)
