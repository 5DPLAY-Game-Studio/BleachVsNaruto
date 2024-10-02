package net.play5d.game.bvn.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;

	public class GameUtils
	{
		public function GameUtils()
		{
		}
		
		public static function isInTop(child:DisplayObject,container:DisplayObjectContainer = null,globalPoint:Point = null):Boolean
		{
			if(!container)
			{
				container = child.stage;
			}
			if(!globalPoint)
			{
				globalPoint = new Point(1,1);
				try
				{
					globalPoint.x = container.stage.stageWidth / 2;
					globalPoint.y = container.stage.stageHeight / 2;
				}
				catch(err)
				{
				}
			}
			var arr:Array = container.getObjectsUnderPoint(globalPoint);
			if(arr && arr.length > 0)
			{
				var top:DisplayObject = arr.pop();
				if(child is DisplayObjectContainer)
				{
					var dc:DisplayObjectContainer = child as DisplayObjectContainer;
					return dc.contains(top);
				}
				else
				{
					return top == child;
				}
			}
			return false;
		}
		
		
	}
}