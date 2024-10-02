package net.play5d.kyo
{
	import flash.net.SharedObject;

	public class KyoSharedObject
	{
		public function KyoSharedObject()
		{
		}
		
		public static function load(id:String):Object{
			var so:SharedObject = SharedObject.getLocal(id);
			var d:Object = so.data;
			so.close();
			return d;
		}
		
		public static function save(id:String , data:Object):void{
			var so:SharedObject = SharedObject.getLocal(id);
			so.clear();
			for(var i:String in data){
				so.data[i] = data[i];
			}
			so.flush();
			so.close();
		}
		
		public static function deletee(id:String):void{
			var so:SharedObject = SharedObject.getLocal(id);
			so.clear();
		}
		
	}
}