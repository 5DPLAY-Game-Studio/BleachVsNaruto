package net.play5d.kyo.display.shapes
{
	import flash.display.Shape;
	
	public class Line extends Shape
	{
		public function Line(width:Number , thinkness:Number = 1 , color:int = 0 , angel:int = 0)
		{
			super();
			graphics.beginFill(color , 1);
			graphics.drawRect(0,0,width,thinkness);
			graphics.endFill();
			this.rotation = angel;
		}
	}
}