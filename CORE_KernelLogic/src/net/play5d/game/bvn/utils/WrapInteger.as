package net.play5d.game.bvn.utils
{
	public class WrapInteger
	{
		private var _w:int		
		private var _offset:int;
		private static var _rndArr:Array = [1,2,3,4,5,6,7,8,9];
		
		public function WrapInteger(v:int)
		{			
			_offset = Math.floor(Math.random() * _rndArr.length);
			_w = v ^ _rndArr[_offset];
			
		}
		public function setValue(v:int):void
		{
			_offset = Math.floor(Math.random() * _rndArr.length);
			_w = v ^ _rndArr[_offset];
		}
		
		public function getValue():int
		{//trace(_w,_offset);
			return _w ^ _rndArr[_offset];
		}
		
		public function toString():String
		{			
			var tmp:int = _w ^ _rndArr[_offset];			
			return tmp.toString();
		}
	}
}