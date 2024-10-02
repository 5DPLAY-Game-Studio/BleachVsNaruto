package net.play5d.game.bvn.fighter.models
{
	import net.play5d.game.bvn.interfaces.IGameSprite;

	public class FighterHitModel
	{
		private var _hitObj:Object = {};  //攻击定义
		private var _fighter:IGameSprite;
		
		public function FighterHitModel(fighter:IGameSprite)
		{
			_fighter = fighter;
		}
		
		public function destory():void{
			_hitObj = null;
			_fighter = null;
		}
		
		public function clear():void{
			_hitObj = {};
		}
		
		public function getHitVO(id:String):HitVO{
			return _hitObj[id];
		}
		
		public function getAll():Object{
			return _hitObj;
		}
		
		public function getHitVOLike(likeId:String):Vector.<HitVO>{
			var hv:Vector.<HitVO> = new Vector.<HitVO>();
			for(var i:String in _hitObj){
				if(i.indexOf(likeId) != -1) hv.push(_hitObj[i]);
			}
			return hv;
		}
		
		/**
		 * 通过MC的名字取HitVO 
		 * @param name
		 */
		public function getHitVOByDisplayName(name:String):HitVO{
			var hv:HitVO = getHitVO(name);
			if(hv) return hv;
			
			if(name.indexOf('atm') == -1) return null;
			var id:String = name.replace('atm','');
			return getHitVO(id);
		}
		
//		public function isHitAreaDisplay(display:DisplayObject):Boolean{
//			return display.name.indexOf('atm') != -1;
//		}
		
		/**
		 * 增加HitVO，重复将直接替换 
		 * @param id
		 * @param obj
		 * 
		 */
		public function addHitVO(id:String , obj:Object):void{
			var hv:HitVO = new HitVO(obj);
			hv.owner = _fighter;
			hv.id = id;
			_hitObj[id] = hv;
		}
		
		public function setPowerRate(v:Number):void{
			for each(var i:HitVO in _hitObj){
				i.powerRate = v;
			}
		}
		
	}
}