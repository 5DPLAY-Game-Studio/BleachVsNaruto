package net.play5d.kyo.utils
{
	import flash.display.DisplayObject;
	import flash.text.TextFormat;

	public class KyoUIUtils
	{
		public static function setBarScaleX(ui:DisplayObject,per:Number):void{
			if(per > 0){
				ui.scaleX = per;
				ui.visible = true;
			}else{
				ui.visible = false;
			}
		}
		
		/**
		 * 设置FLASH的UI组件字体 
		 * @param ui
		 * @param font 对应TextFormat的值，默认为宋体，12号
		 */
		public static function setFlashUIFont(ui:* , font:Object = null):void{
			var tft:TextFormat = new TextFormat();
			tft.font = '宋体';
			tft.size = 12;
			if(font) KyoUtils.setValueByObject(tft,font);
			
			try{
				ui.setStyle("textFormat",tft);
				ui.textField.setStyle('textFormat', tft);
				ui.dropdown.setRendererStyle("textFormat", tft); 
			}catch(e:Error){}
		}
	}
}