package net.play5d.game.bvn.fighter.vos
{
	import flash.geom.Point;
	
	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.interfaces.BaseGameSprite;
	import net.play5d.game.bvn.interfaces.IGameSprite;

	public class MoveTargetParamVO
	{
		public var x:Number;
		public var y:Number;
		
		public var followMcName:String;
		
		public var target:IGameSprite;
		
		//移动速度，为NULL时，直接移动到相应位置
		public var speed:Point;
		
		/**
		 * params:{
		 * 		x:Number X位置
		 * 		y:Number Y位置
		 * 		followmc:String 按MC的位置移动目标，MC名称
		 * 		speed:Number|{x:Number,y:Number} 移动速度，0或不设置时，直接移动到相应位置
		 * }
		 */
		public function MoveTargetParamVO(params:Object = null)
		{
			if(!params) return;
			
			x = params.x != undefined ? params.x : 0;
			y = params.y != undefined ? params.y : 0;
			followMcName = params.followmc != undefined ? params.followmc : null;
			
			if(params.speed){
				speed = new Point();
				if(params.speed is Number){
					speed.x = speed.y = params.speed * GameConfig.SPEED_PLUS;
				}else{
					speed.x = params.speed.x != undefined ? params.speed.x * GameConfig.SPEED_PLUS : 0;
					speed.y = params.speed.y != undefined ? params.speed.y * GameConfig.SPEED_PLUS : 0;
				}
			}
			
		}
		
		public function setTarget(v:IGameSprite):void{
			target = v;
			if(target is BaseGameSprite){
//				(target as BaseGameSprite).isApplyG = false;
				(target as BaseGameSprite).setVelocity(0,0);
			}
		}
		
		public function clear():void{
			if(target){
				if(target is BaseGameSprite){
					(target as BaseGameSprite).isApplyG = true;
				}
			}
		}
		
	}
}