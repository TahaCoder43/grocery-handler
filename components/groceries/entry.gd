extends PanelContainer

class_name Entry

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
) -> Entry:
	var hbox = $"MarginContainer/HBoxContainer"
	hbox.get_node("time").text = purchased_on
	hbox.get_node("name").text = grocery
	hbox.get_node("amount").text = amount + " " + unit
	hbox.get_node("price").text = price + " " + currency
	return self
