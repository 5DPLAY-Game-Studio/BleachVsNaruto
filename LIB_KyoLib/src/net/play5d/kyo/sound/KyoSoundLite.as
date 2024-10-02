package net.play5d.kyo.sound
{
	import flash.media.Sound;
	import flash.net.URLRequest;

	public class KyoSoundLite
	{
		public function KyoSoundLite()
		{
		}
		
		public static function play(sound:Object, times:int = 1):void{
			var s:Sound;
			if(sound is Class){
				s = new sound();
			}
			if(sound is String){
				s = new Sound(new URLRequest(sound as String));
			}
			if(s) s.play(0,times);
		}
		
	}
}