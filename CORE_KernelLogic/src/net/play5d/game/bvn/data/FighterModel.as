package net.play5d.game.bvn.data
{
	public class FighterModel
	{
		
		private static var _i:FighterModel;
		
		public static function get I():FighterModel{
			_i ||= new FighterModel();
			return _i;
		}
		
		private var _fighterObj:Object;
		
		public function FighterModel()
		{
		}
		
		public function getAllFighters():Object{
			return _fighterObj;
		}
		
		public function getFighters(comicType:int = -1, condition:Function = null):Vector.<FighterVO>{
			var vec:Vector.<FighterVO> = new Vector.<FighterVO>();
			for each(var i:FighterVO in _fighterObj){
				if(condition && !condition(i)) continue;
				if(comicType == -1 || i.comicType == comicType){
					vec.push(i);
				}
			}
			return vec;
		}
		
		public function getFighter(id:String , clone:Boolean = false):FighterVO{
//			return _fighterObj[id];
			var fv:FighterVO = _fighterObj[id];
			if(!fv) return null;
			return clone ? fv.clone() : fv;
		}
		
		public function getFighterName(id:String):String{
			var fv:FighterVO = _fighterObj[id];
			if(!fv) return "N/A";
			return fv.name;
		}
		
		public function getFighterBGM(id:String):BgmVO{
			var fv:FighterVO = getFighter(id);
			if(!fv || !fv.bgm || fv.bgmRate <= 0) return null;
			
			var bv:BgmVO = new BgmVO();
			bv.id = fv.id;
			bv.url = fv.bgm;
			bv.rate = fv.bgmRate;
			return bv;
		}
		
		public function getBossBGM(id:String):BgmVO{
			var bv:BgmVO = new BgmVO();
			bv.id = id;
			bv.rate = 1;
			
			switch(id){
				case 'boss_naruto':
					bv.url = 'bgm/narutoboss.mp3';
					break;
				case 'boss_bleach':
					bv.url = 'bgm/bleachboss.mp3';
					break;
				default:
					return null;
			}
			
			return bv;
		}
		
		public function initByXML(xml:XML):void{
			_fighterObj = {};
			
			for each(var i:XML in xml.fighter){
				var fv:FighterVO = new FighterVO();
				fv.initByXML(i);
				_fighterObj[fv.id] = fv;
			}
			
		}
		
		
	}
}