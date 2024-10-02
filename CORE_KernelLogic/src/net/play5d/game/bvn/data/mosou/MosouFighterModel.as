package net.play5d.game.bvn.data.mosou
{
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;

	public class MosouFighterModel
	{
		private static var _i:MosouFighterModel;
		public static function get I():MosouFighterModel{
			_i ||= new MosouFighterModel();
			return _i;
		}
		
		public function MosouFighterModel()
		{
		}
		
		public var fighters:Vector.<MosouFighterSellVO>;
		private var _inited:Boolean = false;
		
		public function init():void{
			if(!_inited){
				initFighters();
				_inited = true;
			}
		}
		
		public function allCustom():void{
			fighters = new Vector.<MosouFighterSellVO>();
			_inited = true;
		}
		
		private function initFighters():void{
			fighters = new Vector.<MosouFighterSellVO>();
			fighters.push(new MosouFighterSellVO("ichigo", 5000));
			fighters.push(new MosouFighterSellVO("ichigo_zero", 5000));
			
			fighters.push(new MosouFighterSellVO("rukia", 5000));
			fighters.push(new MosouFighterSellVO("renji", 5000));
			fighters.push(new MosouFighterSellVO("naruto", 5000));
			fighters.push(new MosouFighterSellVO("sakura", 5000));
			fighters.push(new MosouFighterSellVO("uryuu", 5000));
			fighters.push(new MosouFighterSellVO("lee", 5000));
			fighters.push(new MosouFighterSellVO("neji", 5000));
			fighters.push(new MosouFighterSellVO("temari", 5000));
			
			fighters.push(new MosouFighterSellVO("chad", 7000));
			fighters.push(new MosouFighterSellVO("karin", 7000));
			fighters.push(new MosouFighterSellVO("gaara", 7000));
			fighters.push(new MosouFighterSellVO("sasuke", 8000));
			fighters.push(new MosouFighterSellVO("orihime", 8000));
			fighters.push(new MosouFighterSellVO("ikkaku", 8000));
			fighters.push(new MosouFighterSellVO("gin", 8000));
			fighters.push(new MosouFighterSellVO("juggo", 8000));
			fighters.push(new MosouFighterSellVO("suigetsu", 8000));
			fighters.push(new MosouFighterSellVO("kakashi", 8000));
			fighters.push(new MosouFighterSellVO("sakura_sr", 8000));
			
			fighters.push(new MosouFighterSellVO("hinata", 8000));
			
			fighters.push(new MosouFighterSellVO("kimimaro", 9000));
			fighters.push(new MosouFighterSellVO("killerbee", 9000));
			
			fighters.push(new MosouFighterSellVO("toushirou", 10000));
			fighters.push(new MosouFighterSellVO("byakuya", 10000));
			fighters.push(new MosouFighterSellVO("jiraiya", 10000));
			fighters.push(new MosouFighterSellVO("orochimaru", 10000));
			fighters.push(new MosouFighterSellVO("deidara", 10000));
			
			fighters.push(new MosouFighterSellVO("soifon", 10000));
			fighters.push(new MosouFighterSellVO("konan", 10000));
			fighters.push(new MosouFighterSellVO("grimmjow", 10000));
			fighters.push(new MosouFighterSellVO("mayuri", 12000));
			
			fighters.push(new MosouFighterSellVO("yoruichi", 15000));
			fighters.push(new MosouFighterSellVO("kenpachi", 15000));
			fighters.push(new MosouFighterSellVO("itachi", 15000));
			fighters.push(new MosouFighterSellVO("pain", 15000));
			fighters.push(new MosouFighterSellVO("ichigo_bankai", 15000));
			fighters.push(new MosouFighterSellVO("naruto_oneTail", 15000));
			fighters.push(new MosouFighterSellVO("sasuke_susanoo", 15000));
			
			fighters.push(new MosouFighterSellVO("ichigo_vizored_half", 18000));
			fighters.push(new MosouFighterSellVO("naruto_hermit", 18000));
			
			fighters.push(new MosouFighterSellVO("starrk", 20000));
			fighters.push(new MosouFighterSellVO("ulquiorra", 23000));
			
			fighters.push(new MosouFighterSellVO("obito", 25000));
			
			fighters.push(new MosouFighterSellVO("aizen", 40000));
			fighters.push(new MosouFighterSellVO("madara", 42000));
			
			fighters.push(new MosouFighterSellVO("kenshin", 45000));
			
//			var userFighters:Vector.<MosouFighterVO> = GameData.I.mosouData.getFighterData();
			
//			for each(var i:MosouFighterVO in userFighters){
//				for each(var j:MosouFighterSellVO in fighters){
//					if(j.id == i.id) j.sold = true;
//				}
//			}
			
		}
		
		public function addFighter(id:String, price:int):void{
			if(containsFighter(id)){
				trace("MosouFighterModel.addFighter 重复：" + id);
				return;
			}
			fighters.push(new MosouFighterSellVO(id, price));
		}
		
		private function containsFighter(id):Boolean{
			for each(var f:MosouFighterSellVO in fighters){
				if(f.id == id) return true;
			}
			return false;
		}
		
		
	}
}