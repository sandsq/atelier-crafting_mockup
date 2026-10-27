extends Node2D

signal bonuses_changed(new_bonuses: Dictionary[RecipeNode, WeaponBonus])
signal passives_changed(new_passives: Array[String])
signal crafting_status_changed(new_status: bool)

@export var primary_node: RecipeNode

## This assumes recipe nodes can only provide one type of bonus, which will be true for now
var bonuses: Dictionary[RecipeNode, WeaponBonus]
## can't do nested collections, but this is a dictonary of RecipeNode : Array[String]
var passives: Dictionary
var can_craft: bool = false

@onready var recipe_node_holder = $Nodes


func _ready() -> void:
	if primary_node != recipe_node_holder.get_child(0):
		push_error("primary node should be the first node in the recipe")
	for recipe_node in recipe_node_holder.get_children():
		recipe_node.bonus_changed.connect(_on_bonus_changed)
		recipe_node.passive_changed.connect(_on_passive_changed)
		recipe_node.node_completed.connect(_on_node_completed)
		recipe_node.node_uncompleted.connect(_on_node_uncompleted)

func return_all_recipe_nodes():
	return recipe_node_holder.get_children()

func _on_bonus_changed(node: RecipeNode, bonus: WeaponBonus):
	bonuses[node] = bonus
	emit_signal("bonuses_changed", bonuses)

func _on_passive_changed(node: RecipeNode, new_passives: Array[String]):
	passives[node] = new_passives 
	emit_signal("passives_changed", passives)

func _on_node_completed(node: RecipeNode):
	if node == primary_node:
		can_craft = true
		emit_signal("crafting_status_changed", true)
	
func _on_node_uncompleted(node: RecipeNode):
	if node == primary_node:
		can_craft = false
		emit_signal("crafting_status_changed", false)
