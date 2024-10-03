package net.play5d.game.bvn.win.utils
{
	import net.play5d.game.bvn.win.ctrls.LANServerCtrl;
	import net.play5d.game.bvn.win.data.LanGameModel;

	public class SocketMsgFactory
	{
		public function SocketMsgFactory()
		{
		}
		
		/**
		 * 寻找主机 
		 */
		public static function createFindHostMsg():Object{
			var msg:Object = {};
			msg.type = MsgType.FIND_HOST;
			return msg;
		}
		
		/**
		 * 寻找主机返回 
		 */
		public static function createFindHostBackMsg():Object{
			var msg:Object = {};
			msg.type = MsgType.FIND_HOST_BACK;
			msg.host = LANServerCtrl.I.host.toJson();
			return msg;
		}
		
		/**
		 * 加入游戏 
		 */
		public static function createJoinMsg():Object{
			var o:Object = {};
			o.type = MsgType.JOIN;
			o.name = LanGameModel.I.playerName;
			return o;
		}
		
		/**
		 * 加入游戏成功 
		 */
		public static function createJoinSuccMsg():Object{
			var o:Object = {};
			o.type = MsgType.JOIN_BACK;
			o.success = true;
			return o;
		}
		
		/**
		 * 加入房间
		 */
		public static function createJoinInMsg():Object{
			var o:Object = {};
			o.type = MsgType.JOIN_IN;
			o.name = LanGameModel.I.playerName;
			return o;
		}
		
		/**
		 * 加入游戏失败
		 */
		public static function createJoinFailMsg(msg:String = null):Object{
			var o:Object = {};
			o.type = MsgType.JOIN_BACK;
			o.success = false;
			o.msg = msg;
			return o;
		}
		
		/**
		 * 踢出房间
		 */
		public static function createKickOutMsg(msg:String = null):Object{
			var o:Object = {};
			o.type = MsgType.KICK_OUT;
			o.msg = msg;
			return o;
		}
		
		/**
		 * 消息 
		 */
		public static function createChart(chart:String , name:String):Object{
			var o:Object = {};
			o.type = MsgType.CHART;
			o.msg = chart;
			o.name = name;
			return o;
		}
		
		/**
		 * 开始游戏 
		 */
		public static function createStartGame():Object{
			var o:Object = {};
			o.type = MsgType.START_GAME;
			return o;
		}
		
	}
}