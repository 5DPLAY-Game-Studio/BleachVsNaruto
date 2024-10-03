package net.play5d.game.bvn.win.data
{

	public class SocketInputData
	{
		
		public var up:Boolean;
		public var down:Boolean;
		public var left:Boolean;
		public var right:Boolean;
		
		public var attack:Boolean;
		public var jump:Boolean;
		public var dash:Boolean;
		public var skill:Boolean;
		public var superSkill:Boolean;
		public var special:Boolean;
		
		public function SocketInputData()
		{
		}
		
//		public static function isInputMsg(msg:String):Boolean{
//			return msg.substr(0,6) == "INPUT|";
//		}
		
		public function clear():void{
			up = false;
			down = false;
			left = false;
			right = false;
			
			attack = false;
			jump = false;
			dash = false;
			skill = false;
			superSkill = false;
			special = false;
		}
		
//		public static function getMSG():String{
//			var vs:Array = [
//				GameInputer.down();
//			
//			];
//			return vs.join(",");
//		}
		
	}
}