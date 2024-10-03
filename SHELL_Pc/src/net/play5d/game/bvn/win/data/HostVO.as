package net.play5d.game.bvn.win.data
{
	public class HostVO
	{
		public var ip:String;
		public var tcpPort:int;
		public var udpPort:int;
		
		public var ownerName:String;
		
		public var name:String;
		public var password:String;
		public var gameMode:int = 1;
		
		/**
		 * 状态：0=正常，1=满 
		 */
		public var status:int = 0;
		
		public var updateTime:Date = new Date();
		
		public function HostVO()
		{
		}
		
		public function toJson():String{
			var o:Object = {
//				ip:ip,
//				tcpPort: tcpPort,
//				udpPort: udpPort,
				ownerName:ownerName,
				name:name,
				password:password,
				gameMode:gameMode,
				updateTime:updateTime.time,
				status:status
			};
			var s:String = JSON.stringify(o);
			return s;
		}
		
		public function readJson(json:String):void{
			var o:Object = JSON.parse(json);
//			ip = o.ip;
//			tcpPort = o.tcpPort;
//			udpPort = o.udpPort;
			ownerName = o.ownerName;
			name = o.name;
			password = o.password;
			gameMode = o.gameMode;
			updateTime.time = o.updateTime;
			status = o.status;
		}
		
		public function getListName():String{
			var after:String = status == 1 ? "(满)" : "";
			return name;
		}
		
		public function getGameModeStr():String{
			switch(gameMode){
				case 1:
					return "TEAM VS - 小队对战";
					break;
				case 2:
					return "SINGLE VS - 单人对战";
					break;
			}
			return null;
		}
		
	}
}