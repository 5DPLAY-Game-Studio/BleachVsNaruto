package net.play5d.kyo.display
{
	public class BMCCacher
	{
		private var _total:int;
		private var _amount:int;
		public function BMCCacher(totalAmount:int = -1)
		{
			_total = totalAmount;
		}
		
		private var _cacheObj:Object = {};
		public function cache(id:String , insarray:Array):void{
			_amount ++;
			if(_total != -1 && _amount > _total){
				clean();
			}
			_cacheObj[id] = insarray;
		}
		public function get(id:String):Array{
			return _cacheObj[id];
		}
		public function remove(id:String):void{
			var a:Array = _cacheObj[id];
			for each(var b:BitmapMCFrameVO in a){
				b.destory();
				b = null;
			}
			a = null;
			delete _cacheObj[id];
		}
		
		public function clean():void{
			for each(var i:Array in _cacheObj){
				for each(var j:* in i){
					if(j is BitmapMCFrameVO){
						var b:BitmapMCFrameVO = j;
						b.destory();
					}
					j = null;
				}
				i = null;
			}
			_cacheObj = {};
			_amount = 0;
		}
		
	}
}