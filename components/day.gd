extends PanelContainer

var purchases_scene = preload("res://app/groceries/groceries.tscn")
var date: String

func init(day: String, spenditure: int, provided_date: String) -> PanelContainer:
	date = provided_date
	$"Button/MarginContainer/HBoxContainer/day".text = "Day " + day
	$"Button/MarginContainer/HBoxContainer/spenditure".text = str(spenditure) + " PKR"
	return self


func _on_button_pressed() -> void:
	print("Changing scene")
	var purchases_instance = purchases_scene.instantiate()
	get_tree().root.add_child(purchases_instance)
	purchases_instance.init(date)
	get_node("/root/days_view").queue_free()
