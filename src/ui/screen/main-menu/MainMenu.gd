extends Control

func _ready() -> void:
	pass

func _on_play_button_pressed() -> void:
	var selection_scene = "res://src/ui/screen/main-menu/selection/Selection.tscn"
	get_tree().change_scene_to_file(selection_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
