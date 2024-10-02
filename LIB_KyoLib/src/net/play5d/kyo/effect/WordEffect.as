package net.play5d.kyo.effect
{
	import com.greensock.TweenLite;
	
	import flash.text.TextField;
	
	/**
	 * 文字效果类 
	 * @author kyo
	 */
	public class WordEffect
	{
		/**
		 * 一个字一个字的出现 
		 * @param txt
		 * @param gapTime 间隔（秒）
		 */
		public static function showOneByOne(txt:TextField,gapTime:Number = 0.03,finish:Function = null):void{
			var str:String = txt.text;
			var len:int = str.length;
			txt.text = '';
			for(var i:int ; i < len ; i++){
				var f:Function;
				if(finish != null){
					if(i == len - 1){
						f = finish;
					}
				}
				TweenLite.delayedCall(i * gapTime,function(ci:int):void{
					txt.appendText(str.charAt(ci));
					if(f != null) f();
				},[i]);
			}
		}
	}
}