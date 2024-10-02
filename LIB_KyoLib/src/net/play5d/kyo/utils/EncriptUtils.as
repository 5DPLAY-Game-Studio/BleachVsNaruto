package net.play5d.kyo.utils
{
	import com.adobe.crypto.AES;
	import com.adobe.crypto.MD5;
	import com.hurlant.util.Hex;
	
	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	public class EncriptUtils
	{
		public function EncriptUtils()
		{
		}
		
		public static function md5(bytes:ByteArray):String{
			return hashBytes(bytes);
		}
		
		private static function hashBytes(fileBytes:ByteArray):String{
			var length:int = fileBytes.length;
			var time:int = getTimer();
			var bytes:ByteArray;
			
			if(length < 1024 * 2){
				bytes = fileBytes;
			}else{
				bytes = new ByteArray();
				bytes.writeBytes(fileBytes, 0, 1024);
//				bytes.writeBytes(fileBytes, int(length * 0.5), 1024);
				bytes.writeBytes(fileBytes, length - 1024, 1024);
			}
			
			var hash:String = MD5.hashBinary(bytes);
			return hash;
		}
		
		/**
		 * 加密 AES 
		 * @param source  String | ByteArray
		 * @param key
		 * @param iv
		 * @return 
		 */
		public static function encriptAES(source:Object, key:String, iv:String):ByteArray{
			var keyByte:ByteArray = Hex.toArray(key);
			var ivByte:ByteArray = Hex.toArray(iv);
			
			var aes:AES = new AES(keyByte, ivByte, "aes-128-cbc", "null");
			
			var byte:ByteArray;
			
			if(source is String){
				byte = new ByteArray();
				byte.writeUTFBytes(source as String);
			}
			if(source is ByteArray){
				byte = source as ByteArray;
			}
			
			var encryptBytes:ByteArray = aes.encrypt(byte);
			
			return encryptBytes;
		}
		
		public static function decryptAES(code:ByteArray, key:String, iv:String):String{
			var byte:ByteArray = decryptAESBytes(code, key, iv);
			
			byte.position = 0;
			var decode:String = byte.readUTFBytes(byte.length);
			
			return decode;
		}
		
		public static function decryptAESBytes(code:ByteArray, key:String, iv:String):ByteArray{
			var keyByte:ByteArray = Hex.toArray(key);
			var ivByte:ByteArray = Hex.toArray(iv);
			
			var aes:AES = new AES(keyByte, ivByte, "aes-128-cbc", "null");
			var byte:ByteArray = aes.decrypt(code);
			
			return byte;
		}
		
	}
}