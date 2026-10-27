extends Control
class_name RecipeNode

## when a node is completed, send itself in the signal. The node that has this as a prereq will be notified which prereq has been completed and the corresponding arrow will turn green. 
signal node_completed(node: RecipeNode)
signal node_uncompleted(node: RecipeNode)
signal bonus_changed(node: RecipeNode, new_bonus: WeaponBonus)
signal passive_changed(node: RecipeNode, passives: Array[String])
signal remove_all_pressed(node: RecipeNode, materials: Array[CraftingMaterial])

## at >= fill_thresholds[0] of an element put into this node, give the first tier of stats. At >= fill_thresholds[1] of an element, give the second tier of bonuses. Etc.
@export var fill_thresholds: Array[int] = [1, 3]
## see fill_thresholds. 
@export var stats_at_thresholds: Array[WeaponBonus] = []
@export var elemental_requirement: Elements.Elements = Elements.Elements.FIRE
@export var prerequisites: Array[RecipeNode]

var crafting_materials_in_node: Array[CraftingMaterial] = []
## for simplicitly, as long as the first threshold is complete, it will be considered complete
var is_complete: bool = false:
	set(value):
		is_complete = value
		if value:
			background.color = Color(0.9, 1.0, 0.9)
			emit_signal("node_completed", self)
		else:
			background.color = Color(1.0, 1.0, 1.0)
			emit_signal("node_uncompleted", self)
## Track which prereq corresponds to which arrow. See signal node_completed.
var prereq_to_line: Dictionary[RecipeNode, Line2D]
var can_remove_items: Dictionary[RecipeNode, bool]
var passives: Array[String]

@onready var background = $VBoxContainer/PanelContainer/Background
@onready var material_holder = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MaterialHolder
@onready var fill_indicator_holder = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/FillIndicatorHolder
@onready var elemental_indicator_text = $VBoxContainer/ElementalIndicatorText

func _ready() -> void:
	if fill_thresholds.is_empty():
		push_error("fill_thresholds cannot be empty; recipe nodes must accept at least one item")
	for i in range(0, fill_thresholds.size() - 1):
		var n1 = fill_thresholds[i]
		var n2 = fill_thresholds[i + 1]
		if fill_thresholds.size() <= 1 and n2 <= n1:
			push_error("fill thresholds must be strictly increasing but %s at position %s is <= %s at position %s" % [n2, i + 1, n1, i])
	for i in range(0, fill_thresholds[-1]):
		var fill_indicator = ColorRect.new()
		fill_indicator.color = Color(0.5, 0.5, 0.5)
		fill_indicator.custom_minimum_size = Vector2(10, 10)
		fill_indicator_holder.add_child(fill_indicator)

	match elemental_requirement:
		Elements.Elements.FIRE:
			elemental_indicator_text.text = "Elemental requirement: Fire"
			elemental_indicator_text.add_theme_color_override("default_color",  Color(1.0, 0.2, 0.2))
		Elements.Elements.EARTH:
			elemental_indicator_text.text = "Elemental requirement: Earth"
			elemental_indicator_text.add_theme_color_override("default_color", Color(0.8, 0.6, 0.4))

	await get_tree().process_frame
	for prereq in prerequisites:
		var prereq_line = draw_arrow_from_prereq(prereq)
		prereq_to_line[prereq] = prereq_line
		# A node will receive a signal from a prereq when that prereq is completed. This way, because nodes draw their prereqs' arrows, we can look up the prereq and its corresponding arrow and change the color
		prereq.node_completed.connect(_on_node_completed)
		prereq.node_uncompleted.connect(_on_node_uncompleted)
		

func draw_arrow_from_prereq(prereq: RecipeNode):
	var node_line = Line2D.new()
	node_line.z_index = 2
	node_line.width = 3.0
	node_line.default_color = Color.DARK_GOLDENROD
	add_child(node_line)
	
	var end_point = Vector2(self.global_position + Vector2(self.size.x / 2.0, self.size.y / 2.0)) * 0.97
	var start_point = prereq.global_position + Vector2(prereq.size.x / 2.0, prereq.size.y / 2.0)
	var relevant_direction = (start_point - end_point).normalized()
	var angle = PI / 4
	var arrow_direction1 = Vector2(relevant_direction.x * cos(angle) - relevant_direction.y * sin(angle), relevant_direction.x * sin(angle) + relevant_direction.y * cos(angle))
	angle = -PI / 4
	var arrow_direction2 = Vector2(relevant_direction.x * cos(angle) - relevant_direction.y * sin(angle), relevant_direction.x * sin(angle) + relevant_direction.y * cos(angle))
	node_line.add_point(node_line.to_local(start_point))
	node_line.add_point(node_line.to_local(end_point))
	node_line.add_point(node_line.to_local(end_point + arrow_direction1 * 50.0))		
	node_line.add_point(node_line.to_local(end_point))
	node_line.add_point(node_line.to_local(end_point + arrow_direction2 * 50.0))
	return node_line
		
func append_to_crafting_materials_in_node(new_material: CraftingMaterial):
	crafting_materials_in_node.append(new_material)
	var relevant_indicator = fill_indicator_holder.get_child(crafting_materials_in_node.size() - 1)
	relevant_indicator.color = Color(0.0, 1.0, 0.5)
	if crafting_materials_in_node.size() >= fill_thresholds[0]:
		is_complete = true
		print("completed %s quantity in %s" % [crafting_materials_in_node.size(), self])

	for i in range(fill_thresholds.size() - 1, -1, -1):
		var fill_threshold = fill_thresholds[i]
		if crafting_materials_in_node.size() == fill_threshold:
			emit_signal("bonus_changed", self, stats_at_thresholds[i])
			break

	if new_material.crafting_material_info.passive_buff != "":
		passives.append(new_material.crafting_material_info.passive_buff)
		emit_signal("passive_changed", self, passives)

	for prereq in prerequisites:
		prereq.can_remove_items[self] = false

func remove_crafting_materials_from_node():
	for child in material_holder.get_children():
		material_holder.remove_child(child)
	for fill_indicator in fill_indicator_holder.get_children():
		fill_indicator.color = Color(0.5, 0.5, 0.5)
	is_complete = false
	# crafting_materials_in_node = []
	emit_signal("bonus_changed", self, null)
	emit_signal("passive_changed", self, [])

	for prereq in prerequisites:
		prereq.can_remove_items[self] = true
	
func return_node_stats():
	pass

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data.item == null:
		print("cannot drop null item")
		return false
	if not data.item is CraftingMaterial:
		print("cannot drop non-CraftingMaterial")
		return false
	if not data.item.crafting_material_info.element == elemental_requirement:
		print("cannot drop element of type %s into slot of type %s" % [data.item.crafting_material_info.element, elemental_requirement])
		return false
	for prereq in prerequisites:
		if not prereq.is_complete:
			print("cannot drop item because prereq %s is not fulfilled" % [prereq])
			return false
	if crafting_materials_in_node.size() < fill_thresholds[-1]:
		# print("can drop %s at %s" % [data, at_position])
		return true
	if crafting_materials_in_node.size() >= fill_thresholds[-1]:
		print("cannot drop item because recipe node is full")
		return false
	print("some other reason material can't be dropped")
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var item: CraftingMaterial = data.item

	item.reparent(material_holder, false)
	print("dropped %s at %s" % [data, at_position])

	append_to_crafting_materials_in_node(item)


func _on_node_completed(node: RecipeNode):
	print("node %s's prereq of %s has been completed" % [self, node])
	prereq_to_line[node].default_color = Color.SEA_GREEN

func _on_node_uncompleted(node: RecipeNode):
	prereq_to_line[node].default_color = Color.DARK_GOLDENROD

func _on_button_pressed() -> void:
	for node in can_remove_items.keys():
		if not can_remove_items[node]:
			print("can't remove items because prereq %s has items in it" % node)
			return

	print("need to handle situations where one node is a prereq for multiple other nodes, as once one postreq is cleared, the prereq is as well")
	remove_crafting_materials_from_node()
	emit_signal("remove_all_pressed", self, crafting_materials_in_node)
	crafting_materials_in_node.clear()
