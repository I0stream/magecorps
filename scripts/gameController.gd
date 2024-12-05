extends Node


var goal: int = 13;
var score: int = 0;

signal playerWon;

func update_score():
	score += 1
	print("rings entered: ", score)
	if score >= goal:
		emit_signal("playerWon")
