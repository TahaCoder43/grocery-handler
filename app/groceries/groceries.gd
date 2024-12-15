extends Control

var item_scene = load("res://new_entry.tscn")
var days_scene = load("res://days.tscn")
var date: String

## item_data: {
## 		grocery: String
##		amount: float
##		unit: String
##		price: float
##		currency: String
##		purchased_on: String
## }
func add_item(item_data: Dictionary) -> PanelContainer:
	print(item_data)
	var item = item_scene.instantiate().init(item_data.grocery, str(item_data.amount), item_data.unit, str(item_data.price), item_data.currency, item_data.purchased_on)
	$"PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/MarginContainer/grocery-list".add_child(item)
	return item

func _on_goback_pressed() -> void:
	var days_instance = days_scene.instantiate()
	get_tree().root.add_child(days_instance)
	get_node("/root/purchases_view").queue_free()

func _on_add_pressed() -> void:
	var add_ribbon = $"PanelContainer/MarginContainer/VBoxContainer/add-ribbon"
	var item_data = add_ribbon.get_data(date)
	add_ribbon.clear()
	var item = add_item(item_data)
	var id = $"Database".add_purchase(item_data.grocery, item_data.amount, item_data.unit, item_data.price, item_data.currency, item_data.purchased_on)
	var freeup = func():
		$"Database".remove_purchase(id)
	item.entry_freed.connect(freeup)

func init(provided_date: String) -> void:
	date = provided_date
	var purchases = $"Database".get_purchases_by_date(date)
	for purchase in purchases:
		var item = add_item(purchase)
		var freeup = func():
			$"Database".remove_purchase(purchase.id)
		item.entry_freed.connect(freeup)

#func _on_name_mouse_entered() -> void: #var name_edit = $"PanelContainer/MarginContainer/VBoxContainer/add-ribbon/name"
	#var name_stylebox = name_edit.get_theme_stylebox("focus")
	#name_stylebox.bg_color = Color(0, 0, 0, 0.5)

#func _on_name_mouse_exited() -> void:
	#var name_edit = $"PanelContainer/MarginContainer/VBoxContainer/add-ribbon/name"
	#var name_stylebox = name_edit.get_theme_stylebox("focus")
	#name_stylebox.bg_color = Color(0, 0, 0, 0.2)
