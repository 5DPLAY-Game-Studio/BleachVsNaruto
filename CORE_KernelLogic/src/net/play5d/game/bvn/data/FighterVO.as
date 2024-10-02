package net.play5d.game.bvn.data
{
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.kyo.utils.KyoRandom;

	public class FighterVO
	{
		
		public var id:String;
		public var name:String;
		public var comicType:int; //0=死神,1=火影
		
		public var fileUrl:String;
		public var startFrame:int;
		
		public var faceUrl:String;
		public var faceBigUrl:String;
		public var faceBarUrl:String;
		public var faceWinUrl:String;
		
		public var contactFriends:Array;
		public var contactEnemys:Array;
		
		public var says:Array;
		
		public var bgm:String;
		public var bgmRate:Number = 1;
		
		public var isAlive:Boolean;
		
//		public var fighter:FighterMain;
		
		private var _cloneKey:Array = ['id','name','comicType','fileUrl','startFrame','faceUrl','contactFriends','contactEnemys','says','faceBigUrl','faceBarUrl','bgm','bgmRate'];
		
		public function FighterVO()
		{
		}
		
		public function initByXML(xml:XML):void{
			
			id = xml.@id;
			name = xml.@name;
			comicType = int(xml.@comic_type);
			
			fileUrl = xml.file.@url;
			startFrame = int(xml.file.@startFrame);
			
			faceUrl = xml.face.@url;
			faceBigUrl = xml.face.@big_url;
			faceBarUrl = xml.face.@bar_url;
			faceWinUrl = xml.face.@win_url;
			
			contactFriends = xml.contact.friend.toString().split(",");
			
			contactEnemys = xml.contact.enemy.toString().split(",");
			
			bgm = xml.bgm.@url;
			bgmRate = Number(xml.bgm.@rate) / 100;
			
			says = [];
			for each(var i:XML in xml.says.say_item){
				says.push(i.children().toString());
			}
			
			if(startFrame != 0 && !bgm){
				trace(id+'没有定义bgm!');
			}
			
		}
		
		public function getRandSay():String{
			return KyoRandom.getRandomInArray(says);
		}
		
		public function clone():FighterVO{
			var fv:FighterVO = new FighterVO();
			for each(var i:String in _cloneKey){
				fv[i] = this[i];
			}
			return fv;
		}
		
	}
}