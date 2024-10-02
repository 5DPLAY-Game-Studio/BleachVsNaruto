package net.play5d.game.bvn.data.mosou
{
	import net.play5d.game.bvn.data.FighterVO;

	public class MosouEnemyVO
	{
		
		public var fighterID:String;
		public var maxHp:int = 0;
		public var atk:int = 0;
		
		public var isBoss:Boolean;
		
		public var wave:MosouWaveVO;
		public var repeat:MosouWaveRepeatVO;
		
		private var exp:int = 10;
		private var money:int = 10;
		
		public var level:int = 1;
		
		public function getExp():int{
			var levelAdd:int = isBoss ? (level * 10) : (level * 2);
			return exp + levelAdd;
		}
		
		public function getMoney():int{
			var levelAdd:int = isBoss ? (level * 5) : (level * 1);
			return money + levelAdd;
		}
		
		public static function create(fighterID:String, maxHp:int = 200, atk:int = 0, isBoss:Boolean = false, exp:int = 10, money:int = 10):MosouEnemyVO{
			var ev:MosouEnemyVO = new MosouEnemyVO();
			
			ev.fighterID = fighterID;
			ev.isBoss = isBoss;
			
			if(maxHp > 0) ev.maxHp = maxHp;
			
			if(atk > 0) ev.atk = atk;
			
			if(exp > 0){
				ev.exp = exp;
			}else{
				ev.exp = isBoss ? 100 : 10;
			}
			
			if(money > 0){
				ev.money = money;
			}else{
				ev.money = isBoss ? 100 : 10;
			}
			
			return ev;
		}
		
//		public static function createByXML(xml:XML):Vector.<MosouEnemyVO>{
//			var id:String = xml.@id.toString();
//			var hp:int = xml.@hp;
//			var amount:int = xml.@amount;
//			var isBoss:Boolean = xml.@isBoss == "true";
//			var result:Vector.<MosouEnemyVO> = new Vector.<MosouEnemyVO>();
//			for(var i:int; i < amount; i++){
//				var mv:MosouEnemyVO = create(id, hp, isBoss);
//				result.push(mv);
//			}
//			return result;
//		}
		
		public static function createByJSON(json:Object):Vector.<MosouEnemyVO>{
			var id:String = json.id;
			var hp:int = json.hp;
			var atk:int = json.atk;
			var amount:int = json.amount;
			var isBoss:Boolean = json.isBoss;
			var exp:int = json.exp;
			var money:int = json.money;
			
			var result:Vector.<MosouEnemyVO> = new Vector.<MosouEnemyVO>();
			for(var i:int; i < amount; i++){
				var mv:MosouEnemyVO = create(id, hp, atk, isBoss, exp, money);
				result.push(mv);
			}
			return result;
		}
		
		public function MosouEnemyVO()
		{
		}
	}
}