package net.play5d.kyo.crypto
{
	import com.hurlant.crypto.symmetric.AESKey;
	import com.hurlant.crypto.symmetric.CBCMode;
	import com.hurlant.crypto.symmetric.DESKey;
	import com.hurlant.util.Base64;
	
	import flash.utils.ByteArray;

	/**
	 * ...
	 * @author bardpub
	 */
	public class DES
	{
		public function DES() 
		{
		}
		
		public static var keystr:String = "123456";
		
		public static function encrypt(str:String):String{
			var des:DESKey = getDESKey();
			var tmp:ByteArray = string2byteArray(str);
			des.encrypt(tmp);
			var as3Str:String = Base64.encodeByteArray(tmp);
			return as3Str;
		}
		
		public static function decrypt(str:String):String{
			var des:DESKey = getDESKey();
			var tmp:ByteArray = Base64.decodeToByteArray(str);
			des.decrypt(tmp);
			return byteArray2string(tmp);
		}
		
		private static function string2byteArray(str:String):ByteArray 
		{ 
			var bytes:ByteArray; 
			if (str) 
			{
				bytes=new ByteArray();
				bytes.writeUTFBytes(str);
			} 
			return bytes; 
		} 

		private static function byteArray2string(bytes:ByteArray):String 
		{ 
			var str:String; 
			if (bytes) 
			{ 
				bytes.position=0; 
				str=bytes.readUTFBytes(bytes.length); 
			} 
			return str; 
		}
		
		private static function getDESKey():DESKey{
			var key:ByteArray = new ByteArray();                        
			key.writeUTFBytes(keystr);
			var  iv:ByteArray= new ByteArray();
			iv.writeUTFBytes(keystr);
			var des:DESKey = new DESKey(key);                        
			var cbc:CBCMode = new CBCMode(des);
			cbc.IV = iv;
			return des;
		}
		
	}
	
}