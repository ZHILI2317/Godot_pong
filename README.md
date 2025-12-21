# Pong游戏项目

一个基于Godot引擎开发的经典Pong游戏，包含完整的游戏逻辑、碰撞检测和音效系统。

## 🎮 功能特点

- ✅ 经典Pong游戏玩法
- ✅ 完整的碰撞检测系统
- ✅ 音效反馈机制
- ✅ 实时分数显示
- ✅ AI对手控制
- ✅ 响应式碰撞角度

## 📦 安装与运行

### 系统要求

- **Godot引擎**：4.0或更高版本
- **操作系统**：Windows/macOS/Linux

### 安装步骤

1. 克隆或下载本项目
2. 确保已安装Godot引擎4.0+版本
3. 在Godot引擎中打开项目文件 `pong_game.tscn`
4. 点击运行按钮开始游戏


## 📁 项目结构

```
pong_game/
├── pong_game.gd           # 游戏主脚本文件
├── pong_game.tscn         # 游戏场景文件
├── pong.wav               # 碰撞音效文件
├── 7SDD-1.ttf             # 字体文件
├── icon.svg               # 游戏图标
└── README.md              # 项目说明文档
```

## 🎯 游戏规则

1. 玩家控制左侧球拍，AI控制右侧球拍
2. 球碰到球拍或边界时会反弹
3. 球穿过对方球门时得分
4. 游戏没有时间限制，持续进行

## 🎮 操作说明

- **W键**：向上移动球拍
- **S键**：向下移动球拍

## 🎨 自定义设置

### 修改游戏参数

在 `pong_game.gd` 文件中可以调整以下参数：

```gdscript
# 游戏速度设置
var ball_speed = 400      # 球的移动速度（像素/秒）
var paddle_speed = 800    # 球拍的移动速度（像素/秒）

# 音效设置
var sound_cooldown = 0.3  # 音效冷却时间（秒）
```

### 修改音效

1. 将新的音频文件放入项目根目录
2. 在Godot编辑器中打开 `pong_game.tscn`
3. 选择 `CollisionSound` 节点
4. 在检查器面板中修改 `Stream` 属性，选择新的音频文件

## 🔧 开发说明

### 核心游戏逻辑

- **`move_ball()`**：处理球的移动和碰撞检测
- **`detect_boundary_collision()`**：检测球与上下边界的碰撞
- **`detect_left_paddle_collision()`**：检测球与玩家球拍的碰撞
- **`detect_right_paddle_collision()`**：检测球与AI球拍的碰撞
- **`move_ai_paddle()`**：AI球拍的移动逻辑
- **`play_collision_sound()`**：处理碰撞音效播放

### 音效系统

游戏使用Godot的 `AudioStreamPlayer` 节点播放碰撞音效，具有以下特点：
- 帧内防重复播放
- 时间冷却机制
- 基于碰撞位置的音效触发