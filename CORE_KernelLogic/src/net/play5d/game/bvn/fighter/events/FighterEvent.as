package net.play5d.game.bvn.fighter.events
{
	import flash.events.Event;
	import net.play5d.game.bvn.interfaces.BaseGameSprite;

	public class FighterEvent extends Event
	{
		public static const BIRTH:String = "BIRTH"; //出生
		
		public static const FIRE_BULLET:String = "FIRE_BULLET"; //发射子弹
		public static const ADD_ATTACKER:String = "ADD_ATTACKER"; //加入攻击元件
//		public static const ADD_ASSISTER:String = "ADD_ASSISTER"; //加入辅助
		public static const HIT_TARGET:String = "HIT_TARGET"; //攻击到目标
		
		public static const HURT:String = "HURT"; //被打
		public static const HURT_RESUME:String = "HURT_RESUME"; //从被打状态恢复
		public static const HURT_DOWN:String = "HURT_DOWN"; //被击倒
		
		public static const DEFENSE:String = "DEFENSE"; //防御
		
		public static const IDLE:String = "IDLE"; //恢复正常
		
		public static const DIE:String = "DIE"; //死亡
		public static const DEAD:String = "DEAD"; //死透（死亡&击倒）
		
		public static const DO_ACTION:String = "DO_ACTION";
		public static const DO_SPECIAL:String = "DO_SPECIAL";
		
		public var params:*;
		public var fighter:BaseGameSprite;
		
		public function FighterEvent(type:String,bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type,bubbles,cancelable);
		}
	}
}