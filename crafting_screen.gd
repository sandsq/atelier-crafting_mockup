extends Control


var bonuses_by_stat: Dictionary[Stats.WeaponStats, int]

@onready var recipe = $Control/Recipe
@onready var inventory = $CanvasLayer/VBoxContainer/Inventory
## should have label corresponding to every stat, that way updates can be per stat. But for simplicity, just delete and recreate labels every time
@onready var item_stats_container = $CanvasLayer/VBoxContainer/ItemStats

func _ready() -> void:
	recipe.bonuses_changed.connect(_on_bonuses_changed)
	var recipe_nodes = recipe.return_all_recipe_nodes()
	for recipe_node in recipe_nodes:
		recipe_node.remove_all_pressed.connect(_on_recipe_node_materials_removed)


func _on_bonuses_changed(bonuses: Dictionary[RecipeNode, WeaponBonus]):
	bonuses_by_stat.clear()
	for node in bonuses:
		var weapon_bonus = bonuses[node]
		if weapon_bonus == null:
			pass
		else:
			var bonus_stat = weapon_bonus.stat
			var bonus_amount = weapon_bonus.bonus_amount
			if bonus_stat not in bonuses_by_stat.keys():
				bonuses_by_stat[bonus_stat] = bonus_amount
			else:
				bonuses_by_stat[bonus_stat] += bonus_amount

	for label_child in item_stats_container.get_children():
		label_child.queue_free()
	for bonus_stat in bonuses_by_stat:
		var stat_label = Label.new()
		## this will be integers because the enums don't have names. fix this later
		stat_label.text = "%s: +%s" % [bonus_stat, bonuses_by_stat[bonus_stat]]
		item_stats_container.add_child(stat_label)
		
func _on_recipe_node_materials_removed(node: RecipeNode, materials: Array[CraftingMaterial]):
	print("node %s removd all materials" % node)
	for crafting_material in materials:
		inventory.place_item_in_next_slot(crafting_material)
