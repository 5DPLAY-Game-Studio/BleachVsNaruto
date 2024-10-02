package net.play5d.kyo.utils
{
	public class ArrayLite
	{
		public var length:int;
		private var _o:Object;
		public function ArrayLite()
		{
			super();
			_o = {};
		}
		
		public function push(id:Object , value:*):void{
			if(!_o[id]) length ++;
			_o[id] = value;
		}
		
		public function getItem(id:Object):*{
			return _o[id];
		}
		
		public function remove(id:Object):void{
			if(!_o[id]) return;
			
			delete _o[id];
			length--;
			if(length < 0) length = 0;
		}
	}
}