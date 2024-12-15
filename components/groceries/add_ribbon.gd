extends HBoxContainer

func clear():
	$"name".text = ""
	$"time".text = ""
	$"amount/HBoxContainer/LineEdit".text = ""
	$"price/HBoxContainer/LineEdit".text = ""

func is_time_valid(time: String) -> bool:
	var time_regex = RegEx.create_from_string(r'^\d{2}:\d{2}:\d{2}$')
	var time_match = time_regex.search(time)
	if time_match == null:
		return false
	var time_array = time.split(":")
	var hours = int(time_array[0])
	if hours > 23 or 0 > hours:
		return false
	var minutes = int(time_array[1])
	if minutes > 59 or 0 > minutes:
		return false
	var seconds = int(time_array[2])
	if seconds > 59 or 0 > seconds:
		return false
	return true
	
func get_data(date: String):
	var lineedit_time = $"time".text
	var time: String
	var today_date = Time.get_date_string_from_system()
	if is_time_valid(lineedit_time):
		time = lineedit_time
	elif date == today_date:
		time = Time.get_time_string_from_system()
	else:
		time = "12:00:00"
	var datetime = date + "T" + time
	return {
		grocery = $"name".text,
		amount = $"amount/HBoxContainer/LineEdit".text as float,
		unit = $"amount/HBoxContainer/MenuButton".text,
		price = $"price/HBoxContainer/LineEdit".text as float,
		currency = $"price/HBoxContainer/MenuButton".text,
		purchased_on = datetime
	}
