package net.play5d.game.bvn.win.data
{
	import flash.net.Socket;

	public class ClientVO
	{
		public var ip:String;
		public var port:int;
		public var name:String;
		
		public var socket:Socket;
		
		public function get id():String{
			return ip;
		}
		
		
		public function ClientVO()
		{
		}
	}
}