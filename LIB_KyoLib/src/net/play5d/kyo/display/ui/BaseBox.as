package net.play5d.kyo.display.ui
{
	import flash.display.Sprite;
	import flash.events.Event;

	public class BaseBox extends Sprite
	{
		public var gapX:Number;
		public var gapY:Number;
		
		protected var _instances:Array;
		
		private var _repeater:KyoRepeater;
		
		public final function get repeater():KyoRepeater
		{
			return _repeater;
		}

		public final function set repeater(value:KyoRepeater):void
		{
			_repeater = value;
			buildByRepeater();
		}
		
		protected function build():void{}
		
		protected function buildByRepeater():void{}

		public final function get instances():Array{
			return _instances;
		}
		
		public final function set instances(v:Array):void{
			_instances = v;
			build();
		}
		
		public function BaseBox()
		{
		}
		
		public function removeAll(e:Event):void{
			for(var i:String in _instances)delete _instances[i];
			_instances = null;
		}
	}
}