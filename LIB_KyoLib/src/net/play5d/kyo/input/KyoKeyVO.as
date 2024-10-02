package net.play5d.kyo.input
{
	public class KyoKeyVO
	{
		public function KyoKeyVO(name:String, code:int)
		{
			this.name = name;
			this.code = code;
		}

		public var name:String;
		public var code:int;
		public var isDown:Boolean;

		public function toString():String{
			return name;
		}

		public function clone():KyoKeyVO{
			return new KyoKeyVO(name,code);
		}

	}
}
