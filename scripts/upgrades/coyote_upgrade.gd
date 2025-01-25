class_name CoyoteUpgrade
extends BaseUpgrade

@export var extra_seconds = 2

func upgrade(player):
  var run_state = player.get_node("StateMachine/Run")
  var timer_duration = run_state.coyote_duration
  print("Previous Coyote Time ", timer_duration )
  print("Added time to Coyote Timer!")
  timer_duration += extra_seconds
  print("New Coyote Time ", timer_duration)
  run_state.coyote_duration = timer_duration