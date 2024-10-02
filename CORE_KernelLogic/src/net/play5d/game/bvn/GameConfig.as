package net.play5d.game.bvn
{
	import flash.display.StageQuality;
	import flash.geom.Point;

	public class GameConfig
	{
		public static var TOUCH_MODE:Boolean = false;
		
		
		public static const G:Number = 12; //重力
		public static const G_ADD:Number = 1.2; //重力加速度
		public static const G_ON_FLOOR:Number = 4; //在地面上的重力
		
		public static const GAME_SIZE:Point = new Point(800,600); //游戏尺寸
		public static var GAME_SCALE:Point = new Point(1,1); //游戏与场景之间的比例
		
		public static var FPS_GAME:int = 60;  //游戏帧率
		public static const FPS_UI:int = 30;  //UI界面帧率
		public static const FPS_ANIMATE:int = 30; //动画帧率
		public static var FPS_SHINE_EFFECT:int = 15; //闪光效果的FPS
		
		public static var QUALITY_UI:String = StageQuality.HIGH; //UI界面画质
		
		public static var QUALITY_GAME:String = StageQuality.MEDIUM; //游戏界面画质
		
		public static var SHOW_HOW_TO_PLAY:Boolean = true;
		
		public static var ALLOW_SHOW_HP_TEXT:Boolean = true;
		
		public static function setGameFps(v:int):void{
			FPS_GAME = v;
			SPEED_PLUS = SPEED_PLUS_DEFAULT;
//			HURT_FRAME_OFFSET = v == 30 ? 4 : 3;
		}
		
		//默认速度比率
		public static function get SPEED_PLUS_DEFAULT():Number{
			return FPS_ANIMATE / FPS_GAME;
		}
		public static var SPEED_PLUS:Number = SPEED_PLUS_DEFAULT; //速度比率
		
		public static const BULLET_HOLD_FRAME_PLUS:Number = 2; //发射的波，子弹的持续时间比率
		
		public static const JUMP_DELAY_FRAME:int = 2; //跳时，停留在起跳时的帧数，延时(动画FPS)
		public static const JUMP_DELAY_FRAME_AIR:int = 1; //跳时，停留在起跳时的帧数，延时(动画FPS)
		public static const JUMP_DAMPING:Number = 0.5; //跳跃阻尼
		
		public static const HURT_JUMP_FRAME:int = 15; //击飞时，在空中停留的最短时间(动画FPS)
		public static const HURT_GAP_FRAME:int = 4; //受攻击的间隔(无敌时间 动画FPS)
		
		public static const BREAK_DEF_GAP_FRAME:int = 4; //破防时的无敌时间(动画FPS)
		public static const BREAK_DEF_DOWN_GAP_FRAME:int = 10; //破防时的无敌时间(击飞)(动画FPS)
		public static const BREAK_DEF_HOLD_FRAME:int = 0.7 * 60; //破防时的停顿(动画FPS)
		
		public static const DEFENSE_GAP_FRAME:int = 4; //防御攻击的间隔(动画FPS)
		public static const DEFENSE_DAMPING_X:Number = 1; //被打时的速度阻尼X
		public static const DEFENSE_GAP_FRAME_DOWN:int = 8; //防御击倒型攻击的间隔(动画FPS)
		public static const DEFENSE_LOSE_HP_RATE:Number = 0.05; //防御攻击时的受伤比率
		
		public static const DEFENSE_HOLD_FRAME_MIN:int = 5; //防御击倒型攻击的间隔(动画FPS)
		public static const DEFENSE_HOLD_FRAME_MAX:int = 10; //防御击倒型攻击的间隔(动画FPS)
		public static const DEFENSE_HOLD_FRAME_DOWN:int = 10; //防御击倒型攻击的间隔(动画FPS)
		
		public static const HURT_DAMPING_X:Number = 0.1; //被打时的速度阻尼X
		public static const HURT_DAMPING_Y:Number = 0.5; //被打时的速度阻尼Y
		public static const HURT_Y_ADD_INAIR:Number = 3; //被打时，在空中时，被打到空中时的Y增加
		public static const HURT_Y_ADD:Number = 6; //被打到空中时的Y增加
		
		public static const STEEL_HURT_GAP_FRAME:int = 4; //刚身受攻击的间隔(无敌时间 动画FPS)
		public static const STEEL_HURT_DOWN_GAP_FRAME:int = 10; //刚身受攻击(击飞)的间隔(无敌时间 动画FPS)
		
		public static const STEEL_HURT_HP_PERCENT:Number = 0.65; //刚身受攻击的损血百分比
		public static const STEEL_SUPER_HURT_HP_PERCENT:Number = 0.3; //刚身(超级)受攻击的损血百分比
		
		public static const HURT_FLY_DAMPING_X:Number = 0; //被击飞时的速度阻尼X
		public static const HURT_FLY_DAMPING_Y:Number = 0.5; //被击飞时的速度阻尼Y
		
		public static const HIT_FLOOR_DAMPING_X:Number = 2; //被击飞时的，接触到地面的阻尼X
		public static const HIT_FLOOR_DAMPING_X_HEAVY:Number = 4; //被重击地面时，接触到地面的阻尼X
		
		public static const HIT_FLOOR_TAN_Y_MIN:Number = 3; //被击飞时的，接触到地面弹起的Y，最小值
		public static const HIT_FLOOR_TAN_Y_MAX:Number = 8; //被击飞时的，接触到地面弹起的Y，最大值
		
		public static const HIT_DOWN_FRAME:int = 15; //在地面躺上时间
		public static const HIT_DOWN_FRAME_HEAVY:int = 30; //重击到地面时，躺的时间
		
		public static const HIT_DOWN_BY_HITY:int = 5; //当hity大于该值时，执行直接击倒，重击效果
		
		public static const NO_TOUCH_BAN_ON_VECY:int = 5; //当vecY大于该值时，不能站在空中的板上
		
		public static var HURT_FRAME_OFFSET:int = 3; //受击时间补正，帧数
		public static const X_SIDE_OFFSET:int = 10; //角色边界距离补正，像素
		
		public static const HURT_DOWN_JUMP_FRAME:int = 20; //倒地起身的帧数
		public static const HURT_DOWN_JUMP_DAMPING:int = 1; //倒地起身的速度减值
		
		public static const USE_ENERGY_CD:Number = 0.8; //使用能量后，等待一定时间后自动加能量（秒）
		public static const ENERGY_ADD_NORMAL:Number = 2; //每一帧增加的能量
		public static const ENERGY_ADD_DEFENSE:Number = 0.8; //防御时每一帧增加的能量
		public static const ENERGY_ADD_ATTACKING:Number = 1.1; //攻击时每一帧增加的能量
		public static const ENERGY_ADD_OVER_LOAD_PERFRAME:Number = 0.6; //每一帧增加的能量(超载)
		public static const ENERGY_ADD_OVER_LOAD_RESUME:Number = 30; //体力到达多少时，恢复超载
		
		public static const QI_ADD_HIT_BISHA_RATE:Number = 0; // 0.02 必杀攻击到对方的气增量
		public static const QI_ADD_HIT_RATE:Number = 0.17; //攻击到对方的气增量
		public static const QI_ADD_HIT_BULLET_RATE:Number = 0.1; //攻击到对方的气增量
		public static const QI_ADD_HIT_ATTACKER_RATE:Number = 0.13; //攻击到对方的气增量
		public static const QI_ADD_HIT_ASSISTER_RATE:Number = 0.15; //辅助到对方的气增量
		public static const QI_ADD_HIT_MAX:Number = 15; //攻击到对方的气增加最大值
		public static const QI_ADD_HURT_RATE:Number = 0.08; //受到对方攻击时的气增量
		public static const QI_ADD_HURT_MAX:Number = 20; //受到对方攻击时的气增加最大值
		
		public static const FUZHU_QU_ADD_PERFRAME:Number = 0.2; //每一帧增加的辅助气量
		
		public static const CAMERA_TWEEN_SPD:Number = 2.5;
		
		public static const FIGHTER_HP_MAX:int = 1000;
		
		public static var MAP_LOGO_STATE:int = 0; //是否显示地图中的LOGO 0=不显示，1=显示
		
		public static var SHOW_UI_STATUS:int = 0; //UI显示模式（A   第）
		
	}
}