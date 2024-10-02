package net.play5d.game.bvn.ui
{
	import flash.filters.DropShadowFilter;
	
	import net.play5d.kyo.display.BitmapText;
	
	public class Text extends BitmapText
	{
		public function Text(color:uint = 0xffffff, size:int = 20)
		{
			super(true, color, [new DropShadowFilter()]);
			
			font = "Arial";
			fontSize = size;
			
		}
		
		public override function get textWidth():Number{
			return _tf.textWidth;
		}
		
		public override function get textHeight():Number{
			return _tf.textHeight;
		}

		
	}
}