package net.play5d.kyo.display.shapes
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class Box extends Sprite
	{
		public function Box(width:Number , height:Number , color:int = 0 , alpha:Number = 1 , orgin:Point = null)
		{
			super();
			graphics.beginFill(color,alpha);
			graphics.drawRect(
				orgin ? -orgin.x : 0 ,
				orgin ? -orgin.y : 0 ,
				width ,
				height);
			graphics.endFill();
		}
	}
}