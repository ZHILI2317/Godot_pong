extends Node2D

# ================================
# 游戏参数
# ================================

# 移动速度
var ball_speed = 400  # 球的移动速度（像素/秒）
var paddle_speed = 400  # 球拍的移动速度（像素/秒）

# 球的状态
var ball_direction = Vector2(1, 1)  # 球的当前移动方向

# 游戏得分
var player1_score = 0  # 玩家1（左侧）的分数
var player2_score = 0  # 玩家2（右侧，AI）的分数

# 音效管理
@onready var collision_sound = $CollisionSound  # 引用场景中的AudioStreamPlayer节点
var accumulated_time = 0.0  # 累积游戏运行时间（秒）
var last_sound_time = 0.0  # 最后一次播放音效的时间（秒）
var sound_cooldown = 0.3  # 音效冷却时间（秒）
var sound_played_this_frame = false  # 一帧内是否已播放过音效的标记
var collision_detected = false  # 标记是否已经检测到碰撞

# ================================
# 节点引用（@onready变量）
# ================================

# UI元素
@onready var player_score_label = $HUD/PlayerScoreLabel  # 玩家分数显示标签
@onready var cpu_score_label = $HUD/CPUScoreLabel  # AI分数显示标签

# ================================
# 生命周期函数
# ================================

func _ready():
	# 初始化随机数生成器
	randomize()
	
	# 设置球的初始方向
	# 球初始向右移动，y方向随机（-1到1之间）
	ball_direction = Vector2(1, randf() * 2 - 1).normalized()
	
	# 初始化分数显示
	update_score_display()
	
	# 检查音效节点设置
	setup_sound_player()

# 每帧调用的游戏逻辑
func _process(delta):
	# 累积游戏运行时间
	accumulated_time += delta
	# 执行所有游戏逻辑
	update_game_state(delta)

# ================================
# 音效系统
# ================================

# 设置音效播放器（不再需要，因为使用场景中的节点）
func setup_sound_player():
	# 确保音频流已设置
	if not collision_sound.stream:
		print("警告：CollisionSound节点的音频流未设置")

# 播放碰撞音效
func play_collision_sound():
	# 检查音效播放器是否存在
	if not collision_sound:
		return
	
	# 使用累积的游戏运行时间
	var current_time = accumulated_time
	
	# 检查条件：本帧未播放过 + 超过冷却时间
	if not sound_played_this_frame and (current_time - last_sound_time) >= sound_cooldown:
		# 播放音效
		collision_sound.play()
		
		# 设置本帧已播放标志
		sound_played_this_frame = true
		
		# 更新最后播放时间
		last_sound_time = current_time

# ================================
# 核心游戏逻辑
# ================================

# 更新游戏状态（所有游戏逻辑的入口点）
func update_game_state(delta):
	# 移动球
	move_ball(delta)
	
	# 移动AI球拍
	move_ai_paddle(delta)
	
	# 处理玩家输入
	handle_player_input(delta)
	
	# 检查得分
	check_score()

# 移动球的函数
func move_ball(delta):
	# 重置帧内碰撞标志
	sound_played_this_frame = false
	collision_detected = false
	
	# 计算球的新位置
	$Ball.position += ball_direction * ball_speed * delta
	
	# 检测并处理与上下边界的碰撞
	detect_boundary_collision()
	
	# 检测并处理与左侧球拍的碰撞
	if not collision_detected:
		detect_left_paddle_collision()
	
	# 检测并处理与右侧球拍的碰撞
	if not collision_detected:
		detect_right_paddle_collision()
	
	# 确保方向向量是单位向量（保持速度一致）
	ball_direction = ball_direction.normalized()

# 检测上下边界碰撞
func detect_boundary_collision():
	# 使用原始代码的方式检测边界碰撞
	# 顶部边界碰撞检测
	if $Ball.position.y <= 0:
		# 确保球不会移出边界
		$Ball.position.y = 0
		
		# 反转垂直方向
		ball_direction.y = -ball_direction.y
		
		# 设置碰撞检测标志
		collision_detected = true
		
		# 播放音效
		play_collision_sound()
	
	# 底部边界碰撞检测
	elif $Ball.position.y >= 600 - $Ball.size.y:
		# 确保球不会移出边界
		$Ball.position.y = 600 - $Ball.size.y
		
		# 反转垂直方向
		ball_direction.y = -ball_direction.y
		
		# 设置碰撞检测标志
		collision_detected = true
		
		# 播放音效
		play_collision_sound()

# 检测与左侧玩家球拍的碰撞
func detect_left_paddle_collision():
	# 使用原始代码的碰撞检测逻辑
	if ($Ball.position.x <= $LeftPaddle.position.x + $LeftPaddle.size.x and
		$Ball.position.x >= $LeftPaddle.position.x and
		$Ball.position.y + $Ball.size.y >= $LeftPaddle.position.y and
		$Ball.position.y <= $LeftPaddle.position.y + $LeftPaddle.size.y):
		
		# 确保球不会嵌入球拍
		$Ball.position.x = $LeftPaddle.position.x + $LeftPaddle.size.x
		
		# 反转水平方向，确保球向右移动
		ball_direction.x = abs(ball_direction.x)
		
		# 根据击中位置调整反弹角度
		# 计算击中点在球拍上的相对位置（0-1）
		var hit_pos = ($Ball.position.y - $LeftPaddle.position.y) / $LeftPaddle.size.y
		
		# 将相对位置转换为反弹角度（-1到1）
		# 击中顶部向上弹，击中中心直着弹，击中底部向下弹
		ball_direction.y = (hit_pos - 0.5) * 2
		
		# 设置碰撞检测标志
		collision_detected = true
		
		# 播放音效
		play_collision_sound()

# 检测与右侧AI球拍的碰撞
func detect_right_paddle_collision():
	# 使用原始代码的碰撞检测逻辑
	if ($Ball.position.x + $Ball.size.x >= $RightPaddle.position.x and
		$Ball.position.x <= $RightPaddle.position.x + $RightPaddle.size.x and
		$Ball.position.y + $Ball.size.y >= $RightPaddle.position.y and
		$Ball.position.y <= $RightPaddle.position.y + $RightPaddle.size.y):
		
		# 确保球不会嵌入球拍
		$Ball.position.x = $RightPaddle.position.x - $Ball.size.x
		
		# 反转水平方向，确保球向左移动
		ball_direction.x = -abs(ball_direction.x)
		
		# 根据击中位置调整反弹角度
		# 计算击中点在球拍上的相对位置（0-1）
		var hit_pos = ($Ball.position.y - $RightPaddle.position.y) / $RightPaddle.size.y
		
		# 将相对位置转换为反弹角度（-1到1）
		# 击中顶部向上弹，击中中心直着弹，击中底部向下弹
		ball_direction.y = (hit_pos - 0.5) * 2
		
		# 设置碰撞检测标志
		collision_detected = true
		
		# 播放音效
		play_collision_sound()

# 移动AI控制的球拍
func move_ai_paddle(delta):
	# 使用原始代码的AI移动逻辑
	# 只有当球向AI方向移动时才进行追踪
	if ball_direction.x > 0:
		# 计算球的中心y坐标
		var ball_center = $Ball.position.y + $Ball.size.y / 2
		
		# 计算AI球拍的中心y坐标
		var paddle_center = $RightPaddle.position.y + $RightPaddle.size.y / 2
		
		# 根据球的位置调整AI球拍位置
		# 使用10像素的容差范围，避免过度抖动
		if ball_center < paddle_center - 50:
			# 球在上方，向上移动球拍
			$RightPaddle.position.y -= paddle_speed * delta
		elif ball_center > paddle_center + 50:
			# 球在下方，向下移动球拍
			$RightPaddle.position.y += paddle_speed * delta
		
		# 确保AI球拍不超出上下边界
		$RightPaddle.position.y = clamp($RightPaddle.position.y, 0, 600 - $RightPaddle.size.y)

# 处理玩家输入
func handle_player_input(delta):
	# 使用原始代码的玩家输入处理逻辑
	
	# 检测向上移动输入（W键或上箭头键）
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		# 向上移动球拍
		$LeftPaddle.position.y -= paddle_speed * delta
	
	# 检测向下移动输入（S键或下箭头键）
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		# 向下移动球拍
		$LeftPaddle.position.y += paddle_speed * delta
	
	# 确保玩家球拍不超出上下边界
	$LeftPaddle.position.y = clamp($LeftPaddle.position.y, 0, 600 - $LeftPaddle.size.y)

# 检查得分情况
func check_score():
	# 使用原始代码的得分检测逻辑
	
	# 球超出左侧边界（AI得分）
	if $Ball.position.x < 0:
		# AI得分增加
		player2_score += 1
		
		# 重置球，方向向左（AI发球）
		reset_ball(-1)
		
		# 更新分数显示
		update_score_display()
	
	# 球超出右侧边界（玩家得分）
	elif $Ball.position.x > 800:
		# 玩家得分增加
		player1_score += 1
		
		# 重置球，方向向右（玩家发球）
		reset_ball(1)
		
		# 更新分数显示
		update_score_display()

# 更新分数显示
func update_score_display():
	# 使用原始代码的分数显示更新逻辑
	
	# 更新左侧玩家分数显示
	player_score_label.text = str(player1_score)
	
	# 更新右侧AI分数显示
	cpu_score_label.text = str(player2_score)

# 重置球的位置和方向
func reset_ball(direction_x):
	# 使用原始代码的球重置逻辑
	
	# 将球重置到场地中央
	$Ball.position = Vector2(390, 290)
	
	# 设置新的随机方向
	# x方向由参数指定（1向右，-1向左）
	# y方向随机（-1到1之间）
	ball_direction = Vector2(direction_x, randf() * 2 - 1).normalized()
	
	# 重置帧内音效标记
	sound_played_this_frame = false
