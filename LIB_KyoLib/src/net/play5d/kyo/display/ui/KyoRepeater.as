package net.play5d.kyo.display.ui
{
	public class KyoRepeater
	{
		public var dataProvider:Array;
		public var bindClass:Class;
		public var bindProperty:Object;
		public function KyoRepeater()
		{
		}
		
		public function getItems():Array{
			var a:Array = [];
			for(var i:int ; i < dataProvider.length ; i++){
				a.push(newItem(dataProvider[i]));
			}
			return a;
		}
		
		private function newItem(data:Object):Object{
			var o:Object = new bindClass();
			if(bindProperty){
				if(bindProperty is String)o[bindProperty] = bindProperty in data ? data[bindProperty] : data;
				if(bindProperty is Array)
					for each(var i:String in bindProperty)o[i] = data[bindProperty[i]];
			}
			return o;
		}
		
	}
}