class_name Database extends Node

var db: SQLite = null
var db_info = {
	name = "res://save.db",
	table = "purchase"
}

var schemas = {
	grocery = {
		name = {"data_type": "varchar(50)", "primary_key": true, "not_null": true, "unique": true}
	},
	unit = {
		name = {"data_type": "varchar(10)", "primary_key": true, "not_null": true, "unique": true}
	},
	currency = {
		name = {"data_type": "char(3)", "primary_key": true, "not_null": true, "unique": true}
	},
	purchase = {
		id = {"data_type": "int", "primary_key": true, "not_null": true, "unique": true},
		grocery = {"data_type": "varchar(50)", "foreign_key": "grocery.name", "not_null": true},
		amount = {"data_type": "real", "not_null": true, "default": 1.0},
		unit = {"data_type": "varchar(10)", "foreign_key": "unit.name", "not_null": true, "default": "single"},
		price = {"data_type": "real"},
		currency = {"data_type": "char(3)", "not_null": true, "default": "PKR", "foreign_key": "currency.name"},
		purchased_on = {"data_type": "char(25)", "not_null": true}
	}
}

var map_month_names = {
	"01": "January",
	"02": "February",
	"03": "March",
	"04": "April",
	"05": "May",
	"06": "June",
	"07": "July",
	"08": "Augest",
	"09": "September",
	"10": "October",
	"11": "November",
	"12": "December",
}

func does_table_exist(table_name):
	db.query_with_bindings("SELECT 1 FROM sqlite_schema WHERE tbl_name=? AND type='table'", [table_name])
	var table_does_exist = (db.query_result.size() > 0)
	return table_does_exist
	
func prepare_db():
	db = SQLite.new()
	db.path = db_info.name
	db.open_db()
	for table_name in schemas:
		if not does_table_exist(table_name):
			var schema = schemas[table_name]
			db.create_table(table_name, schema)

func get_purchases():
	db.query("SELECT id, grocery, amount, unit, price, currency, purchased_on FROM purchase")
	return db.query_result

func get_purchases_by_date(date: String):
	db.query_with_bindings(
		"SELECT id, grocery, amount, unit, price, currency, purchased_on FROM purchase
		 WHERE STRFTIME('%F', purchased_on)=?",
		[date]
	)
	return db.query_result

func remove_purchase(id: int):
	db.query_with_bindings("DELETE FROM purchase WHERE id=?", [id])


func add_purchase(grocery: String, amount: int, unit: String, price: float, currency: String, purchased_on: String) -> int:
	db.query("SELECT MAX(id) as max_id FROM purchase")
	var max_id: int = db.query_result[0]["max_id"]
	if max_id == null:
		max_id = 0
	var current_id := max_id + 1
	db.insert_row("purchase", {
		id = current_id,
		grocery = grocery,
		amount = amount,
		unit = unit,
		price = price,
		currency = currency,
		purchased_on = purchased_on,
	})
	return current_id

func get_min_max_purchase_time() -> Dictionary:
	db.query("SELECT STRFTIME('%Y|%m', MIN(purchased_on)) AS first_purchase FROM purchase")
	if db.query_result.size() == 0:
		return {}
	var min_purchase_time: PackedStringArray = db.query_result[0]["first_purchase"].split("|")
	db.query("SELECT STRFTIME('%Y|%m', MAX(purchased_on)) AS last_purchase FROM purchase")
	var max_purchase_time: PackedStringArray = db.query_result[0]["last_purchase"].split("|")
	return {
		min = min_purchase_time,
		max = max_purchase_time,
	}

func get_needed_month_keys(map_mohnth_names: Dictionary, min_year: int, max_year: int, min_month_in_min_year: int, max_month_in_max_year: int, year_to_check: int) -> Array:
	var month_keys: Array = map_month_names.keys()
	if year_to_check == min_year and year_to_check == max_year:
		month_keys = month_keys.slice(min_month_in_min_year - 1, max_month_in_max_year)
	elif year_to_check == min_year:
		month_keys = month_keys.slice(min_month_in_min_year - 1)
	elif year_to_check == max_year:
		month_keys = month_keys.slice(0, max_month_in_max_year)
	return month_keys

func add_yearmonth_result(db_query_results: Array, mapped_yearmonth_results: Dictionary, year: int, month_name: String) -> Dictionary:
	if db_query_results == []:
		return mapped_yearmonth_results
	var formatted_result := {}
	for purchases_of_day in db_query_results:
		formatted_result[purchases_of_day.purchase_day] = {
			ids = purchases_of_day["ids"].split("|"),
			total_spent = purchases_of_day["total_spent"]
		}
	var yearmonth_key := str(year) + " " + month_name
	mapped_yearmonth_results[yearmonth_key] = formatted_result
	return mapped_yearmonth_results

func add_today(mapped_yearmonth_result: Dictionary) -> Dictionary:
	var today := Time.get_date_dict_from_system()
	var month_number := "%02d" % today.month
	var day_number := "%02d" % today.day
	var month_name: String = map_month_names[month_number]
	var yearmonth := str(today.year) + " " + month_name
	var newyearmonth_purchases: Dictionary = mapped_yearmonth_result.get_or_add(yearmonth, {})
	newyearmonth_purchases.get_or_add(day_number, {"ids": "", "total_spent": 0})
	mapped_yearmonth_result[yearmonth] = newyearmonth_purchases
	return mapped_yearmonth_result
	
## returns { 
## 		YEAR MONTH_NAME: { 
## 			"PURCHASE_DAY": {ids: Array[string], total_spent: int},
##			"01": {ids=["1","2"], total_spent: 5000}
## 			...
## 		},
##  	...
## }
func get_by_time() -> Dictionary:
	var mapped_yearmonth_results := {}
	var purchase_time := get_min_max_purchase_time()
	if purchase_time == {}:
		return {}
	var min_year := int(purchase_time.min[0])
	var max_year := int(purchase_time.max[0])
	var min_month_in_min_year := int(purchase_time.min[1])
	var max_month_in_max_year := int(purchase_time.max[1])
	for year: int in range(min_year, max_year + 1):
		var month_keys: Array = get_needed_month_keys(map_month_names, min_year, max_year, min_month_in_min_year, max_month_in_max_year, year)
		for month_key: String in month_keys: 
			var month_name: String = map_month_names[month_key]
			db.query_with_bindings(
				"SELECT 
					STRFTIME('%d', purchased_on) AS purchase_day,
					GROUP_CONCAT(id,'|') AS ids, 
					SUM(CASE currency WHEN 'PKR' THEN price WHEN 'USD' THEN price*280 END) AS total_spent
				 FROM purchase WHERE STRFTIME('%Y|%m', purchased_on)=?
				 GROUP BY purchase_day",
				[str(year) + "|" + month_key]
			)
			print(db.query_result)
			mapped_yearmonth_results = add_yearmonth_result(db.query_result, mapped_yearmonth_results, year, month_name)
	mapped_yearmonth_results = add_today(mapped_yearmonth_results)
	print("Here's the mapped results ", mapped_yearmonth_results)
	return mapped_yearmonth_results

func _ready() -> void:
	prepare_db()
	print("db prepared")
	
