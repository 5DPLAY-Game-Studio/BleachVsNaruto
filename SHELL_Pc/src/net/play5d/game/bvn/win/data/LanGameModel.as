package net.play5d.game.bvn.win.data
{
	public class LanGameModel
	{
		private static var _i:LanGameModel;
		public static function get I():LanGameModel{
			_i ||= new LanGameModel();
			return _i;
		}
		
		public var playerName:String = "someone";
		
		public function LanGameModel()
		{
		}
	}
}