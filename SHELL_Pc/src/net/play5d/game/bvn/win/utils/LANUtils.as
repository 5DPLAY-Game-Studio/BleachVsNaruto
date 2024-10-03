package net.play5d.game.bvn.win.utils
{
	import net.play5d.game.bvn.GameConfig;

	public class LANUtils
	{
		/**
		 * 锁帧，关键帧
		 */
		private static const _LOCK_KEYFRAME:int = 3;
		
//		public static const CLIENT_SEND_CTRL_GAP:int = 30;
		
//		public static const SERVER_WAIT_CLIENT:int = 30;
		
		/**
		 * 发送同步状态数据间隔
		 */
		private static const _SYNC_GAP:int = 30 * 3;
		
		public static var LOCK_KEYFRAME:int = _LOCK_KEYFRAME;
		public static var SYNC_GAP:int = _SYNC_GAP;
		
		public function LANUtils()
		{
		}
		
		public static function updateParams():void{
			var rate:Number = GameConfig.FPS_GAME / 30;
			LOCK_KEYFRAME = _LOCK_KEYFRAME * rate;
			SYNC_GAP = _SYNC_GAP * rate;
		}
		
		public static function getTimeStr(date:Date):String{
			return formatNum(date.month+1) + "/" + formatNum(date.date) + " " + formatNum(date.hours) + ":" + formatNum(date.minutes);
		}
		
		private static function formatNum(num:int):String{
			if(num < 10) return '0'+num;
			return num.toString();
		}
		
	}
}