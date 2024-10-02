package net.play5d.game.bvn.data
{
	public class AssisterModel
	{
		
		private static var _i:AssisterModel;
		
		public static function get I():AssisterModel{
			_i ||= new AssisterModel();
			return _i;
		}
		
		private var _assisterObj:Object;
		
		public function AssisterModel()
		{
		}
		
		public function getAllAssisters():Object{
			return _assisterObj;
		}
		
		public function getAssisters(comicType:int = -1, condition:Function = null):Vector.<FighterVO>{
			var vec:Vector.<FighterVO> = new Vector.<FighterVO>();
			for each(var i:FighterVO in _assisterObj){
				if(condition && !condition(i)) continue;
				if(comicType == -1 || i.comicType == comicType){
					vec.push(i);
				}
			}
			return vec;
		}
		
		public function getAssister(id:String , clone:Boolean = false):FighterVO{
			return _assisterObj[id];
		}
		
		public function initByXML(xml:XML):void{
			_assisterObj = {};
			
			for each(var i:XML in xml.fighter){
				var fv:FighterVO = new FighterVO();
				fv.initByXML(i);
				_assisterObj[fv.id] = fv;
			}
			
		}
		
		
	}
}