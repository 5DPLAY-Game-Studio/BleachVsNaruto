package net.play5d.kyo.display.ui
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;

	public class KyoMouseOverEffect
	{
		public static const EFFECT_TYPE_HILIGHT:int = 0;
		
		public function KyoMouseOverEffect()
		{
		}
		
		public static function addEffect(display:DisplayObject , effectType:int = 0 , targetDisplay:DisplayObject = null):void{
			targetDisplay ||= display;
			function doEffect(over:Boolean):void{
				switch(effectType){
					case EFFECT_TYPE_HILIGHT:
						if(over){
							var ct:ColorTransform = new ColorTransform();
							ct.redOffset = ct.greenOffset = ct.blueOffset = 128;
							targetDisplay.transform.colorTransform = ct;
						}else{
							targetDisplay.transform.colorTransform = new ColorTransform();
						}
						break;
				}
			}
			
			display.addEventListener(MouseEvent.MOUSE_OVER,function(e:MouseEvent):void{
				doEffect(true);
			});
			display.addEventListener(MouseEvent.MOUSE_OUT,function(e:MouseEvent):void{
				doEffect(false);
			});
		}
		
	}
}