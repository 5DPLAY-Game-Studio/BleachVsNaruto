package net.play5d.game.bvn.win.input
{
	import net.play5d.kyo.utils.KyoUtils;

	public class JoyStickConfigVO
	{
//		public var id:int;
		public var deviceId:String;
		
		public var deviceIsSet:Boolean = false;
		
		public var up2:JoyStickSetVO = new JoyStickSetVO(1,0.5);
		public var down2:JoyStickSetVO = new JoyStickSetVO(1,-0.5);
		public var left2:JoyStickSetVO = new JoyStickSetVO(0,-0.5);
		public var right2:JoyStickSetVO = new JoyStickSetVO(0,0.5);
		
		public var up:JoyStickSetVO = new JoyStickSetVO(16,1);
		public var down:JoyStickSetVO = new JoyStickSetVO(17,1);
		public var left:JoyStickSetVO = new JoyStickSetVO(18,1);
		public var right:JoyStickSetVO = new JoyStickSetVO(19,1);
		
		public var attack:JoyStickSetVO = new JoyStickSetVO(6,1);
		public var jump:JoyStickSetVO = new JoyStickSetVO(4,1);
		public var dash:JoyStickSetVO = new JoyStickSetVO(5,1);
		public var skill:JoyStickSetVO = new JoyStickSetVO(7,1);
		
		public var superSkill:JoyStickSetVO = new JoyStickSetVO(9,1);
		public var special:JoyStickSetVO = new JoyStickSetVO(8,1);
		public var waikai:JoyStickSetVO = new JoyStickSetVO(10,1);
		
		public var back:JoyStickSetVO = new JoyStickSetVO(12,1);
		public var select:JoyStickSetVO = new JoyStickSetVO(13,1);
		
		public function JoyStickConfigVO()
		{
		}
		
		public function readObj(obj:Object):void{
			for(var i:String in obj){
				var o:Object = obj[i];
				if(!this.hasOwnProperty(i)) continue;
				if(this[i] is JoyStickSetVO){
					(this[i] as JoyStickSetVO).readObj(o);
				}else{
					this[i] = o;
				}
			}
		}
		public function toObj():Object{
			var vs:Array = KyoUtils.getItemVaribles(this);
			var o:Object = {};
			for each(var i:String in vs){
				var item:* = this[i];
				if(item is JoyStickSetVO){
					o[i] = (this[i] as JoyStickSetVO).toObj();
				}else{
					o[i] = this[i];
				}
			}
			return KyoUtils.itemToObject(this);
		}
		
	}
}