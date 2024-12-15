extends Control

var month_scene = preload("res://components/month.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	populate_with_months()
	
func populate_with_months() -> void:
	var months_container = $"PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/months"
	var mapped_purchases_of_months = $"Database".get_by_time()
	for month_name in mapped_purchases_of_months:
		var month_data = mapped_purchases_of_months[month_name]
		var month_instance = month_scene.instantiate().init(month_name, month_data)
		months_container.add_child(month_instance)
