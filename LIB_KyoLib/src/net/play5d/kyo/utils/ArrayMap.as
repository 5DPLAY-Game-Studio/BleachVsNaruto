package net.play5d.kyo.utils
{
	public class ArrayMap
	{
		private var _o:Object;
		private var _arr:Array;
		public function ArrayMap()
		{
			super();
			_o = {};
			_arr = [];
		}
		
		public function get length():int{
			return _arr.length;
		}
		
		public function push(id:Object , value:*):void{
			_o[id] = value;
			_arr.push(value);
		}
		
		public function getItemByIndex(index:int):*{
			return _arr[index];
		}
		
		public function getItemById(id:Object):*{
			return _o[id];
		}
		
		public function removeItemById(id:Object):void{
			if(!_o[id]) return;
			
			var index:int = _arr.indexOf(_o[id]);
			if(index != -1){
				_arr.splice(index, 1);
			}
			
			delete _o[id];
			
		}
	}
}

