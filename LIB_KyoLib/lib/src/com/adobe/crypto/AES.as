package com.adobe.crypto{ 
	import com.hurlant.crypto.Crypto; 
	import com.hurlant.crypto.prng.Random; 
	import com.hurlant.crypto.symmetric.ICipher; 
	import com.hurlant.crypto.symmetric.IPad; 
	import com.hurlant.crypto.symmetric.IVMode; 
	import com.hurlant.crypto.symmetric.PKCS5; 
	import com.hurlant.util.Base64; 
	import com.hurlant.util.Hex; 
	
	import flash.utils.ByteArray; 
	
	/** 
	 * AES 算法的加密解密工具类。 
	 * 
	 * @author Fuchun 
	 * @langversion 3.0 
	 * @playerversion Flash 11.1 
	 * @productversion 1.0 
	 */ 
	public class AES { 
		
		/** 
		 * 默认的算法与模式名称。  
		 */  
		public static const DEFAULT_CIPHER_NAME:String = "aes-128-cbc"; 
		
		/** 
		 * 默认的填充模式。<code>pkcs5</code>  
		 */  
		public static const DEFAULT_PADNAME:String = "pkcs5"; 
		
		/** 
		 * 无填充。  
		 */  
		public static const NULL_PADDING:String = "null"; 
		
		private static const RAND:Random = new Random(); 
		
		private var _name:String; 
		// 密钥 
		private var _key:ByteArray; 
		// 向量 
		private var _iv:ByteArray; 
		// 填充模式 
		private var _padName:String; 
		private var _enc:ICipher; 
		private var _dec:ICipher; 
		
		public function AES(key:ByteArray, iv:ByteArray = null, name:String = DEFAULT_CIPHER_NAME, padName:String = DEFAULT_PADNAME) { 
			_name = name; 
			_key = key; 
			_iv = iv; 
			_padName = padName; 
			init(); 
		} 
		
		private function init():void { 
			var _pad:IPad = Crypto.getPad(_padName); 
			_enc = Crypto.getCipher(_name, _key, _pad); 
			_dec = Crypto.getCipher(_name, _key, _pad); 
			if (iv) { 
				if (_enc is IVMode) { 
					var encIvm:IVMode = _enc as IVMode; 
					encIvm.IV = iv; 
				} 
				if (_dec is IVMode) { 
					var decIvm:IVMode = _dec as IVMode; 
					decIvm.IV = iv; 
				} 
			} 
		} 
		
		public static function generateKey(name:String):ByteArray { 
			var keyLength:uint = Crypto.getKeySize(name); 
			var key:ByteArray = new ByteArray(); 
			RAND.nextBytes(key, keyLength); 
			return key; 
		} 
		
		public static function generateIV(name:String, key:ByteArray):ByteArray { 
			var cipher:ICipher = Crypto.getCipher(name, key); 
			var iv:ByteArray = new ByteArray(); 
			RAND.nextBytes(iv, cipher.getBlockSize()); 
			return iv; 
		} 
		
		public function encrypt(input:ByteArray):ByteArray { 
			var src:ByteArray = new ByteArray(); 
			var result:ByteArray = new ByteArray(); 
			src.writeBytes(input, 0, input.length); 
			
			_enc.encrypt(input); 
			result.writeBytes(input, 0, input.length); 
			input.length = 0; 
			input.writeBytes(src, 0, src.length); 
			
			src.clear(); 
			return result; 
		} 
		
		public function decrypt(input:ByteArray):ByteArray { 
			var src:ByteArray = new ByteArray(); 
			var result:ByteArray = new ByteArray(); 
			src.writeBytes(input, 0, input.length); 
			
			_dec.decrypt(input); 
			result.writeBytes(input, 0, input.length); 
			input.length = 0; 
			input.writeBytes(src, 0, src.length); 
			
			src.clear(); 
			return result; 
		} 
		
		public function encryptString(input:String):ByteArray { 
			if (!input || !input.length) { 
				return null; 
			} 
			var inputBytes:ByteArray = new ByteArray(); 
			inputBytes.writeUTFBytes(input); 
			return encrypt(inputBytes); 
		} 
		
		public function encryptString2Hex(input:String):String { 
			var result:ByteArray = encryptString(input); 
			return Hex.fromArray(result); 
		} 
		
		public function encryptString2Base64(input:String):String { 
			var result:ByteArray = encryptString(input); 
			return Base64.encodeByteArray(result); 
		} 
		
		public function decryptString(input:String):ByteArray { 
			if (!input || !input.length) { 
				return null; 
			} 
			var inputBytes:ByteArray = new ByteArray(); 
			inputBytes.writeUTFBytes(input); 
			return decrypt(inputBytes); 
		} 
		
		public function decryptString2Hex(input:String):String { 
			var result:ByteArray = decryptString(input); 
			return Hex.fromArray(result); 
		} 
		
		public function decryptString2Base64(input:String):String { 
			var result:ByteArray = decryptString(input); 
			return Base64.encodeByteArray(result); 
		} 
		
		public function set iv(value:ByteArray):void { 
			_iv = value; 
		} 
		public function get iv():ByteArray { 
			return _iv; 
		} 
	} 
} 