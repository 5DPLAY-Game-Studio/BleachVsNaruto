package net.play5d.kyo.sound
{
	import flash.media.Sound;
	import flash.utils.ByteArray;
	
	public class BytesSound extends Sound
	{
//		private var _bytes:ByteArray;
		
		public function BytesSound(bytes:ByteArray = null)
		{
			super(null, null);
			if(bytes) loadBytes(bytes);
		}
		
		public function loadBytes(v:ByteArray):void{
//			_bytes = v;
			
			v.position = 0;
			
//			var _this:BytesSound = this;
//			
//			function loadNext():void{
//				if(v.bytesAvailable < 1){
//					trace("loadBytes finish");
//					return;
//				}
//				
//				var bytes:ByteArray = new ByteArray();
//				
//				var start:uint = v.position;
//				
//				var len:uint = Math.min(v.bytesAvailable, 40 * 1024);
//				v.readBytes(bytes, 0, len);
//				
//				var end:uint = start + len;
//				
//				trace("loadCompressedDataFromByteArray", start, "-", end);
//				_this.loadCompressedDataFromByteArray(bytes, bytes.bytesAvailable);
//				
//				setTimeout(loadNext, 1);
//			}
//			loadNext();
			
			while(v.bytesAvailable > 0){
				var bytes:ByteArray = new ByteArray();
				
//				var start:uint = v.position;
				
				var len:uint = Math.min(v.bytesAvailable, 40 * 1024);
				v.readBytes(bytes, 0, len);
				
//				trace("loadCompressedDataFromByteArray", start, "-", start + bytes.bytesAvailable);
				this.loadCompressedDataFromByteArray(bytes, bytes.bytesAvailable);
			}
			
			v.clear();
			
		}
		
		
	}
}