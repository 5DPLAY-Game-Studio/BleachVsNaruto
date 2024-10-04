package net.play5d.game.bvn.utils
{
	import net.play5d.game.bvn.interfaces.ILogger;

	public class GameLoger
	{

//		private static var _loger:ILoger;

		public function GameLoger()
		{
		}

		public static function setLoger(v:Object):void{
//			_loger = v;
		}

		public static function log(v:String):void{
//			if(_loger){
//				_loger.log(v);
//			}else{
//				trace(v);
//			}
			trace(v);
		}

	}
}
