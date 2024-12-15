extends Control

var day_scene = preload("res://components/day.tscn")

var shrinked = false
var new_height = 10

func init(yearmonth: String, month_data: Dictionary) -> Control:
	$"VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/Label".text = yearmonth
	populate_with_days(month_data, yearmonth)
	return self

func month_name_to_number(month_name: String) -> String:
	var mapped_month_names_to_numbers = {
		"January": "01",
		"February": "02",
		"March": "03",
		"April": "04",
		"May": "05",
		"June": "06",
		"July": "07",
		"Augest": "08",
		"September": "09",
		"October": "10",
		"November": "11",
		"December": "12",
	}
	return mapped_month_names_to_numbers[month_name]
	
func prepare_date(yearmonth: String, day: String) -> String: 
	var yearmonth_array = yearmonth.split(" ")
	var month = month_name_to_number(yearmonth_array[1])
	var date = yearmonth_array[0] + "-" + month + "-" + day
	return date

func populate_with_days(month_data: Dictionary, yearmonth: String) -> void:
	var days_container: HFlowContainer = $"VBoxContainer/MarginContainer/days"
	for purchase_day in month_data:
		var spenditure_of_day = month_data[purchase_day]["total_spent"]
		var date = prepare_date(yearmonth, purchase_day)
		var day_instance = day_scene.instantiate().init(purchase_day, spenditure_of_day, date)
		days_container.add_child(day_instance)
		

func _on_button_pressed() -> void:
	print("button is pressed...")
	var container = $"VBoxContainer/MarginContainer"
	var expand_toggle = $"VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/expand_toggle"
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	if shrinked:
		shrinked = false
		container.show()
		tween.tween_property(expand_toggle, "rotation_degrees", 0, 0.3)
	else:
		shrinked = true
		container.hide()
		tween.tween_property(expand_toggle, "rotation_degrees", -180, 0.3)

func setup() -> void:
	var expand_toggle = $"VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/expand_toggle"
	expand_toggle.pivot_offset = Vector2(expand_toggle.size[0] / 2, expand_toggle.size[1] / 2)
	
func _ready() -> void:
	self.call_deferred("setup")
