package net.play5d.game.bvn.ui
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import net.play5d.kyo.utils.KyoUtils;

	public class UIUtils
	{
		public static var formatTextFunction:Function;
		public static var DEFAULT_FONT:String = "黑体";
		public static var LOCK_FONT:String = null;
		
		public function UIUtils()
		{
		}
		
		/**
		 * 格式化文本 
		 * @param text
		 * @param textFormatParam 对应TextFormat的属性
		 */
		public static function formatText(text:TextField , textFormatParam:Object = null):void{
			if(textFormatParam){
//				var tf:TextFormat = new TextFormat();
//				tf.font = DEFAULT_FONT;
//				KyoUtils.setValueByObject(tf,textFormatParam);
//				if(LOCK_FONT) tf.font = LOCK_FONT;
//				text.defaultTextFormat = tf;
				
				var tf:TextFormat = new TextFormat();
				if(textFormatParam.font != null) textFormatParam.font = undefined;
				KyoUtils.setValueByObject(tf,textFormatParam);
				text.defaultTextFormat = tf;
				
			}
			
			if(formatTextFunction != null) formatTextFunction(text);
		}
		
	}
}