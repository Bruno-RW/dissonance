extends Control

@onready var start_btn: Button = $ButtonBox/StartButton
@onready var quit_btn: Button = $ButtonBox/QuitButton
@onready var title: Label = $TitleLabel

func _ready() -> void:
	start_btn.pressed.connect(_on_start)
	quit_btn.pressed.connect(func(): get_tree().quit())

func _on_start() -> void:
	get_tree().change_scene_to_file("res://src/ui/screen/game/Game.tscn")
	GameManager.call_deferred("start_game")
