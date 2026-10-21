extends Node

const EXCLUDED_SCENES: Array[String] = [
	"res://inventory/inventory.tscn",
]

func _ready() -> void:
    # Wait until the startup scene has been added.
    call_deferred("_configure_preview")


func _configure_preview() -> void:
    if not OS.has_feature("editor"):
        return

    var scene := get_tree().current_scene
    if scene == null:
        return

    if scene.scene_file_path in EXCLUDED_SCENES:
        return

    var main_path: String = ProjectSettings.get_setting(
        "application/run/main_scene", ""
    )

    if main_path.begins_with("uid://"):
        main_path = ResourceUID.get_id_path(ResourceUID.text_to_id(main_path))

    if scene.scene_file_path == main_path:
        return

    var viewport := get_viewport()
    viewport.size_changed.connect(_center_origin)
    _center_origin()


func _center_origin() -> void:
    var viewport := get_viewport()
    viewport.canvas_transform = Transform2D(
        0.0,
        viewport.get_visible_rect().size / 2.0
    )
