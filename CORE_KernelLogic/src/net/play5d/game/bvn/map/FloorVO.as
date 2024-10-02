package net.play5d.game.bvn.map
{
	public class FloorVO
	{
		public var y:Number = 0;
		public var xFrom:Number = 0;
		public var xTo:Number = 0;
		public function FloorVO()
		{
		}
		
		public function toString():String{
			return "FloorVO::{xFrom:"+xFrom+",xTo:"+xTo+",y:"+y+"}";
		}
		
		public function hitTest(X:Number , Y:Number , SPEED:Number):Boolean{
			//SPEED = 5
			return Y > y - SPEED && Y < y + SPEED && X > xFrom && X < xTo;
		}
		
	}
}