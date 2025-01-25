class_name CoyoteUpgrade
extends BaseUpgrade

@export var extra_seconds = 2

func upgrade(player):
  print("Added time to Coyote Timer!")
  var timer: Timer = player.get_node("CoyoteTimer")
  timer.wait_time += extra_seconds
