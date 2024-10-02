package net.play5d.game.bvn.interfaces
{
	import flash.utils.ByteArray;

	public class GameInterface
	{
		
//		private static var _i:GameInterface;
//		public static function get I():GameInterface{
//			_i ||= new GameInterface();
//			return _i;
//		}
		
		public static var instance:IGameInterface;
		
		public function GameInterface()
		{
		}
		
		public static function getDefaultMenu():Array{
			var a:Array = [
				
				{txt:'TEAM PLAY',cn:'小队模式',children:[
					{txt:'TEAM ACRADE',cn:'闯关模式'},
					{txt:'TEAM VS PEOPLE',cn:'2P对战'},
					{txt:'TEAM VS CPU',cn:'对战电脑'}
				]},
				
				{txt:'SINGLE PLAY',cn:'单人模式',children:[
					{txt:'SINGLE ACRADE',cn:'闯关模式'},
					{txt:'SINGLE VS PEOPLE',cn:'2P对战'},
					{txt:'SINGLE VS CPU',cn:'对战电脑'}
				]},
				
				{txt:'MUSOU PLAY',cn:'无双模式',children:[
					{txt:'MUSOU ACRADE',cn:'无双模式'}
				]},
				
				/*{txt:'SURVIVOR',cn:'挑战模式'},*/ //暂未开放
				{txt:'OPTION',cn:'游戏设置'},
				{txt:'TRAINING',cn:'练习模式'},
				{txt:'CREDITS',cn:'制作组'},
				{txt:'MORE GAMES',cn:'更多游戏'}
			];
			return a;
		}
		
		public static function checkFile(url:String, file:ByteArray):Boolean{
			if(instance) return instance.checkFile(url, file);
			return true;
		}
		
		public static function addMoney(back:Function):void{
			function addMoneyBack(money:*):void{
				var mm:int = int(money);
				if(mm < 1) return;
				if(mm > 5000) return;
				back(mm);
			}
			
			if(instance){
				instance.addMosouMoney(addMoneyBack);
				return;
			}
			addMoneyBack(100 + Math.random() * 500);
		}
		
//		public var moreGames:Function;
//		public var 
		
		
	}
}