package net.play5d.kyo.loader
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;

	public class LoaderBar extends Sprite
	{
		public var color:uint = 0xff0000;
		public var lineColor:uint = 0x426F00;
		public var thinkness:uint = 2;
		public var backColor:uint = 0;
		private var _bar:Shape;
		public var size:Point;

		public function LoaderBar(width:Number = 500, height:Number = 10)
		{
			super();
			size = new Point(width,height);

			initlize();
		}

		public function initlize():void{
			graphics.clear();
			graphics.lineStyle(thinkness,lineColor);
			graphics.beginFill(backColor,1);
			graphics.drawRect(0 , -1,size.x , size.y+1);
			graphics.endFill();

			_bar ||= new Shape();
			_bar.graphics.clear();
			_bar.graphics.beginFill(color,1);
			_bar.graphics.drawRect(0, 0, size.x, size.y);
			_bar.graphics.endFill();

			addChild(_bar);
		}

		public function update(p:Number):void{
			_bar.scaleX = p;
		}

	}
}
