extends Node2D

# 游戏参数
var ball_speed = 400
var ball_direction = Vector2(1, 1)
var paddle_speed = 300
var player1_score = 0
var player2_score = 0

# 两个分数标签 - 分别放在两侧
@onready var player_score_label = $HUD/PlayerScoreLabel
@onready var cpu_score_label = $HUD/CPUScoreLabel

func _ready():
	randomize()
	ball_direction = Vector2(1, randf() * 2 - 1).normalized()
	update_score_display()

func _process(delta):
	move_ball(delta)
	move_ai_paddle(delta)
	handle_player_input(delta)
	check_score()

func move_ball(delta):
	$Ball.position += ball_direction * ball_speed * delta
	
	if $Ball.position.y <= 0 or $Ball.position.y >= 600 - $Ball.size.y:
		ball_direction.y = -ball_direction.y
	
	if ($Ball.position.x <= $LeftPaddle.position.x + $LeftPaddle.size.x and
		$Ball.position.x >= $LeftPaddle.position.x and
		$Ball.position.y + $Ball.size.y >= $LeftPaddle.position.y and
		$Ball.position.y <= $LeftPaddle.position.y + $LeftPaddle.size.y):
		
		ball_direction.x = abs(ball_direction.x)
		var hit_pos = ($Ball.position.y - $LeftPaddle.position.y) / $LeftPaddle.size.y
		ball_direction.y = (hit_pos - 0.5) * 2
	
	if ($Ball.position.x + $Ball.size.x >= $RightPaddle.position.x and
		$Ball.position.x <= $RightPaddle.position.x + $RightPaddle.size.x and
		$Ball.position.y + $Ball.size.y >= $RightPaddle.position.y and
		$Ball.position.y <= $RightPaddle.position.y + $RightPaddle.size.y):
		
		ball_direction.x = -abs(ball_direction.x)
		var hit_pos = ($Ball.position.y - $RightPaddle.position.y) / $RightPaddle.size.y
		ball_direction.y = (hit_pos - 0.5) * 2
	
	ball_direction = ball_direction.normalized()

func move_ai_paddle(delta):
	if ball_direction.x > 0:
		var ball_center = $Ball.position.y + $Ball.size.y / 2
		var paddle_center = $RightPaddle.position.y + $RightPaddle.size.y / 2
		
		if ball_center < paddle_center - 10:
			$RightPaddle.position.y -= paddle_speed * delta
		elif ball_center > paddle_center + 10:
			$RightPaddle.position.y += paddle_speed * delta
		
		$RightPaddle.position.y = clamp($RightPaddle.position.y, 0, 600 - $RightPaddle.size.y)

func handle_player_input(delta):
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		$LeftPaddle.position.y -= paddle_speed * delta
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		$LeftPaddle.position.y += paddle_speed * delta
	
	$LeftPaddle.position.y = clamp($LeftPaddle.position.y, 0, 600 - $LeftPaddle.size.y)

func check_score():
	if $Ball.position.x < 0:
		player2_score += 1
		reset_ball(-1)
		update_score_display()
	
	if $Ball.position.x > 800:
		player1_score += 1
		reset_ball(1)
		update_score_display()

func update_score_display():
	# 分别更新两侧的分数显示
	player_score_label.text = str(player1_score)
	cpu_score_label.text = str(player2_score)

func reset_ball(direction_x):
	$Ball.position = Vector2(390, 290)
	ball_direction = Vector2(direction_x, randf() * 2 - 1).normalized()
