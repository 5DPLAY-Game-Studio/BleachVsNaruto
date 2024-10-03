package net.play5d.game.bvn.win.input
{
	public class JoyStickSetVO
	{
		public var id:int;
		public var value:Number = 0;
		
//		public function get ID():String{
//			return id+'_'+value;
//		}
		
		public function JoyStickSetVO(id:int , value:Number = 1)
		{
			this.id = id;
			this.value = value;
		}
		
		public function readObj(o:Object):void{
			this.id = o.id;
			this.value = o.value;
		}
		
		public function toObj():Object{
			var o:Object = {};
			o.id = this.id;
			o.value = this.value;
			return o;
		}
		
	}
}