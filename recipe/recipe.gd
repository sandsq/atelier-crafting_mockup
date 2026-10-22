extends Node2D

signal bonuses_changed(new_bonuses: Dictionary[RecipeNode, WeaponBonus])

## This assumes recipe nodes can only provide one type of bonus, which will be true for now
var bonuses: Dictionary[RecipeNode, WeaponBonus]

@onready var recipe_node_holder = $Nodes


func _ready() -> void:
	for recipe_nodes in recipe_node_holder.get_children():
		recipe_nodes.bonus_changed.connect(_on_bonus_changed)


func return_all_recipe_nodes():
	return recipe_node_holder.get_children()

func _on_bonus_changed(node: RecipeNode, bonus: WeaponBonus):
	bonuses[node] = bonus
	emit_signal("bonuses_changed", bonuses)
