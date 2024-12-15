extends PanelContainer

class_name NewEntry

signal entry_freed()

func _on_button_pressed() -> void:
	entry_freed.emit()
	queue_free()

func init(
	grocery: String,
	amount: String,
	unit: String,
	price: String,
	currency: String,
	purchased_on: String
) -> NewEntry:
	$"MarginContainer/HBoxContainer/VBoxContainer2/time".text = purchased_on.right(8)
	$"MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/MarginContainer/name".text = grocery
	$"MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/price".text = price + " " + currency
	$"MarginContainer/HBoxContainer/VBoxContainer/amount".text = amount + " " + unit
	return self
