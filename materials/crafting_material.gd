extends Control
class_name CraftingMaterial

@export var crafting_material_info: CraftingMaterialInfo

@onready var container = $VBoxContainer
@onready var icon = $VBoxContainer/ColorRect
@onready var label = $VBoxContainer/MaterialName

func _ready() -> void:
	label.text = crafting_material_info.material_name
	match crafting_material_info.element:
		Elements.Elements.FIRE:
			icon.color = Color(1.0, 0.4, 0.4)
			label.add_theme_color_override("default_color", Color(1.0, 0.4, 0.4))
		#"water":
			#icon.color = Color(0.2, 0.6, 1.0)
		Elements.Elements.EARTH:
			icon.color = Color(0.8, 0.6, 0.4)
			label.add_theme_color_override("default_color", Color(0.8, 0.6, 0.4))
		Elements.Elements.WATER:
			icon.color = Color(0.2, 0.6, 1.0)
			label.add_theme_color_override("default_color", Color(0.2, 0.6, 1.0))
		_:
			print("element %s not found" % crafting_material_info.element)
	icon.custom_minimum_size = Vector2(crafting_material_info.length, crafting_material_info.height)
