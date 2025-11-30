extends Node2D

# 游戏参数
var ball_speed = 400  # 球的移动速度（像素/秒）
var ball_direction = Vector2(1, 1)  # 球的初始移动方向
var paddle_speed = 300  # 球拍的移动速度（像素/秒）
var player1_score = 1000  # 玩家1（左侧）的分数
var player2_score = 0  # 玩家2（右侧，AI）的分数

# 两个分数标签 - 分别放在两侧
@onready var player_score_label = $HUD/PlayerScoreLabel  # 玩家分数显示标签（懒加载）
@onready var cpu_score_label = $HUD/CPUScoreLabel  # AI分数显示标签（懒加载）

func _ready():
	randomize()  # 初始化随机数种子
	# 设置球的随机初始方向：x方向向右，y方向随机（-1到1之间）
	ball_direction = Vector2(1, randf() * 2 - 1).normalized()
	update_score_display()  # 初始化分数显示

func _process(delta):
	# 主游戏循环，每帧调用
	move_ball(delta)  # 移动球
	move_ai_paddle(delta)  # 移动AI控制的球拍
	handle_player_input(delta)  # 处理玩家输入
	check_score()  # 检查得分情况

# 移动球的函数
func move_ball(delta):
	# 根据方向和速度更新球的位置
	$Ball.position += ball_direction * ball_speed * delta
	
	# 检测上下边界碰撞（顶部和底部）
	if $Ball.position.y <= 0 or $Ball.position.y >= 600 - $Ball.size.y:
		ball_direction.y = -ball_direction.y  # 反转y方向（反弹）
	
	# 检测与左侧球拍（玩家）的碰撞
	if ($Ball.position.x <= $LeftPaddle.position.x + $LeftPaddle.size.x and
		$Ball.position.x >= $LeftPaddle.position.x and
		$Ball.position.y + $Ball.size.y >= $LeftPaddle.position.y and
		$Ball.position.y <= $LeftPaddle.position.y + $LeftPaddle.size.y):
		
		ball_direction.x = abs(ball_direction.x)  # 确保球向右移动
		# 根据击中球拍的位置计算反弹角度（顶部击中向上弹，底部击中向下弹）
		var hit_pos = ($Ball.position.y - $LeftPaddle.position.y) / $LeftPaddle.size.y
		ball_direction.y = (hit_pos - 0.5) * 2  # 将0-1的值转换为-1到1的范围
	
	# 检测与右侧球拍（AI）的碰撞
	if ($Ball.position.x + $Ball.size.x >= $RightPaddle.position.x and
		$Ball.position.x <= $RightPaddle.position.x + $RightPaddle.size.x and
		$Ball.position.y + $Ball.size.y >= $RightPaddle.position.y and
		$Ball.position.y <= $RightPaddle.position.y + $RightPaddle.size.y):
		
		ball_direction.x = -abs(ball_direction.x)  # 确保球向左移动
		# 根据击中球拍的位置计算反弹角度
		var hit_pos = ($Ball.position.y - $RightPaddle.position.y) / $RightPaddle.size.y
		ball_direction.y = (hit_pos - 0.5) * 2  # 将0-1的值转换为-1到1的范围
	
	ball_direction = ball_direction.normalized()  # 保持方向向量为单位长度

# 移动AI控制的球拍
func move_ai_paddle(delta):
	# 只有当球向AI方向移动时才进行追踪
	if ball_direction.x > 0:
		var ball_center = $Ball.position.y + $Ball.size.y / 2  # 球的中心y坐标
		var paddle_center = $RightPaddle.position.y + $RightPaddle.size.y / 2  # AI球拍中心y坐标
		
		# 根据球的位置调整AI球拍位置（有10像素的容差）
		if ball_center < paddle_center - 10:
			$RightPaddle.position.y -= paddle_speed * delta  # 向上移动
		elif ball_center > paddle_center + 10:
			$RightPaddle.position.y += paddle_speed * delta  # 向下移动
		
		# 限制AI球拍不超出上下边界
		$RightPaddle.position.y = clamp($RightPaddle.position.y, 0, 600 - $RightPaddle.size.y)

# 处理玩家输入
func handle_player_input(delta):
	# 检测W键或上箭头键 - 向上移动球拍
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		$LeftPaddle.position.y -= paddle_speed * delta
	# 检测S键或下箭头键 - 向下移动球拍
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		$LeftPaddle.position.y += paddle_speed * delta
	
	# 限制玩家球拍不超出上下边界
	$LeftPaddle.position.y = clamp($LeftPaddle.position.y, 0, 600 - $LeftPaddle.size.y)

# 检查得分情况
func check_score():
	# 如果球超出左侧边界（AI得分）
	if $Ball.position.x < 0:
		player2_score += 1  # AI得分增加
		reset_ball(-1)  # 重置球，方向向左（AI发球）
		update_score_display()  # 更新分数显示
	
	# 如果球超出右侧边界（玩家得分）
	if $Ball.position.x > 800:
		player1_score += 1  # 玩家得分增加
		reset_ball(1)  # 重置球，方向向右（玩家发球）
		update_score_display()  # 更新分数显示

# 更新分数显示
func update_score_display():
	# 分别更新两侧的分数显示
	player_score_label.text = str(player1_score)  # 更新玩家分数显示
	cpu_score_label.text = str(player2_score)  # 更新AI分数显示

# 重置球的位置和方向
func reset_ball(direction_x):
	$Ball.position = Vector2(390, 290)  # 将球重置到场地中央
	# 设置新的随机方向：x方向由参数指定，y方向随机
	ball_direction = Vector2(direction_x, randf() * 2 - 1).normalized()
