extends Control

var bonuses_by_stat: Dictionary[Stats.WeaponStats, int]:
	set(value):
		bonuses_by_stat = value
		item_stats_container.draw_bonuses(bonuses_by_stat)
var passives: Dictionary:
	set(value):
		passives = value
		passives_container.draw_passives_as_selection(passives)

@onready var stat_display = $PanelContainer/VBoxContainer/StatDisplay
@onready var item_stats_container = $PanelContainer/VBoxContainer/StatDisplay/ItemStats
@onready var passives_container = $PanelContainer/VBoxContainer/Passives


func _ready() -> void:
	passives_container.passive_chosen.connect(_on_passive_chosen)

func _on_passive_chosen(passive_text: String):
	for label in stat_display.get_children():
		if label is Label:
			label.queue_free()
	var passive_label = Label.new()
	passive_label.text = "Passive: %s" % passive_text
	stat_display.add_child(passive_label)
