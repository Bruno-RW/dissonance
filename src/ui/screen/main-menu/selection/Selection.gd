extends Node

@onready var char_buttons = [
	$CharacterSelector/Buttons/Character1Button,
	$CharacterSelector/Buttons/Character2Button,
	$CharacterSelector/Buttons/Character3Button,
	$CharacterSelector/Buttons/Character4Button
]
@onready var level_buttons = [
	$LevelSelector/Buttons/Level1Button,
	$LevelSelector/Buttons/Level2Button,
	$LevelSelector/Buttons/Level3Button,
	$LevelSelector/Buttons/Level4Button
]

var selected_character: String = "Assault"
var selected_level: String = "res://src/level/scene/Level1.tscn"


#~ === === === BASE METHODS === === === ~#
func _ready() -> void:
	_update_button_states(char_buttons, 0)
	_update_button_states(level_buttons, 0)
	
func _update_button_states(button_list: Array, button_index: int) -> void:
	for btn in button_list:
		btn.disabled = false

	button_list[button_index].disabled = true


#~ === === === CHARACTER BUTTONS === === === ~#
func _on_character_1_button_pressed() -> void:
	selected_character = "Assault"
	_update_button_states(char_buttons, 0)

func _on_character_2_button_pressed() -> void:
	selected_character = "Suppression"
	_update_button_states(char_buttons, 1)

func _on_character_3_button_pressed() -> void:
	selected_character = "Precision"
	_update_button_states(char_buttons,2)

func _on_character_4_button_pressed() -> void:
	selected_character = "Infiltration"
	_update_button_states(char_buttons, 3)


#~ === === === LEVEL BUTTONS === === === ~#
func _on_level_1_button_pressed() -> void:
	selected_level = "res://src/level/scene/Level1.tscn" # Setor de Testes
	_update_button_states(level_buttons, 0)

func _on_level_2_button_pressed() -> void:
	selected_level = "res://src/level/scene/Level2.tscn" # Laboratório de Controle
	_update_button_states(level_buttons, 1)

func _on_level_3_button_pressed() -> void:
	selected_level = "res://src/level/scene/Level3.tscn" # Complexo Industrial
	_update_button_states(level_buttons, 2)

func _on_level_4_button_pressed() -> void:
	selected_level = "res://src/level/scene/Level4.tscn" # A Singularidade
	_update_button_states(level_buttons, 3)


#~ === === === START BUTTON === === === ~#
func _on_start_button_pressed() -> void:
	GameManager.selected_character = selected_character
	GameManager.selected_level_path = selected_level
	
	var game_scene = "res://src/ui/screen/game/Game.tscn"
	get_tree().change_scene_to_file(game_scene)
	
	GameManager.call_deferred("start_game")
