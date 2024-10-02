package net.play5d.game.bvn.data.mosou
{
	import net.play5d.game.bvn.utils.WrapInteger;

	public class MosouFighterSellVO
	{
		public var id:String;
		
//		public var sold:Boolean = false;
//		public var allowSell:Boolean = false;
		
		private var _price:WrapInteger = new WrapInteger(0);
		
		public function MosouFighterSellVO(fighterId:String, price:int)
		{
			this.id = fighterId;
//			this.allowSell = allowSell;
			_price.setValue(price);
		}
		
		public function getPrice():int{
			return _price.getValue();
		}
		
	}
}