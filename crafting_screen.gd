extends Control


var bonuses_by_stat: Dictionary[Stats.WeaponStats, int]
var passives: Dictionary

@onready var recipe = $Control/Recipe
@onready var inventory = $CanvasLayer/VBoxContainer/Inventory
## should have label corresponding to every stat, that way updates can be per stat. But for simplicity, just delete and recreate labels every time
@onready var item_stats_container = $CanvasLayer/VBoxContainer/ItemStats
@onready var passives_container = $CanvasLayer/VBoxContainer/Passives
@onready var crafting_button = $CanvasLayer/VBoxContainer/CraftButton
@onready var crafting_selection_screen_scene = preload("res://crafting_selection_screen.tscn")

func _ready() -> void:
	recipe.bonuses_changed.connect(_on_bonuses_changed)
	recipe.passives_changed.connect(_on_passives_changed)
	
	var recipe_nodes = recipe.return_all_recipe_nodes()
	for recipe_node in recipe_nodes:
		recipe_node.remove_all_pressed.connect(_on_recipe_node_materials_removed)

	recipe.crafting_status_changed.connect(_on_crafting_status_changed)


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

	item_stats_container.draw_bonuses(bonuses_by_stat)
			
func _on_recipe_node_materials_removed(node: RecipeNode, materials: Array[CraftingMaterial]):
	print("node %s removed all materials" % node)
	for crafting_material in materials:
		inventory.place_item_in_next_slot(crafting_material)


func _on_passives_changed(new_passives: Dictionary):
	print("new passives %s" % new_passives)
	passives.clear()
	passives = new_passives.duplicate()
	passives_container.draw_passives(new_passives)
	
func _on_crafting_status_changed(new_status: bool):
	if new_status:
		crafting_button.disabled = false
	else:
		crafting_button.disabled = true
		
func _on_craft_button_pressed() -> void:
	var crafting_selection_screen = crafting_selection_screen_scene.instantiate()
	self.add_child(crafting_selection_screen)
	crafting_selection_screen.bonuses_by_stat = bonuses_by_stat
	crafting_selection_screen.passives = passives
