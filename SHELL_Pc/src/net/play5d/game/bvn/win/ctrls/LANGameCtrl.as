package net.play5d.game.bvn.win.ctrls
{
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.win.sockets.SocketClient;
	import net.play5d.game.bvn.win.views.lan.LANGameState;

	public class LANGameCtrl
	{
		
		public static const PORT_UDP_SERVER:int = 17477;
		public static const PORT_UDP_CLIENT:int = 17478;
		
		public static const PORT_TCP:int = 17511;
		
		private static var _i:LANGameCtrl;
		public static function get I():LANGameCtrl{
			_i ||= new LANGameCtrl();
			return _i;
		}
		
		public var gameMode:int;
		public var userName:String = "test";
		
		private var _client:SocketClient;
		
		public function LANGameCtrl()
		{
		}
		
		public function goLANGameState():void{
			this.gameMode = gameMode;
			MainGame.stageCtrl.goStage(new LANGameState());
		}
		
	}
}