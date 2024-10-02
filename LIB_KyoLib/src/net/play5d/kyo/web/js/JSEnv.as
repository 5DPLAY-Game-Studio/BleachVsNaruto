package net.play5d.kyo.web.js
{
	import flash.external.*;
	import flash.utils.*;
	
	
	
	public dynamic class JSEnv extends Proxy
	{
		// an instance refered to window
		public static var $:JSEnv = new JSEnv(0);
		
		
		/********** callback **********/	
		private static var _init:* =
			ExternalInterface.addCallback("Notify", handleNotify);
		
		private static var FN:Array = [];
		private static function handleNotify(id:uint, This:String, ...args):void
		{
			var AS_Args:Array = [];
			var arg:*;
			
			for each(arg in args)
			{
				AS_Args.push(toAS(arg));
			}
			
			FN[id].apply(toAS(This), AS_Args);
		}
		/*********************************/
		
		
		private static function InsertArg(base:Array, args:Array):Array
		{
			var arg:*;
			for each(arg in args)
			{
				base.push(toJS(arg));
			}
			
			return base;
		}
		
		/**
		 * js function proxy
		 */
		private static function JS_Proxy(id:int):Function
		{
			return function(...args):*
			{
				var arr:Array;
				var ret:*;
				
				if(this == "[object global]")
				{
					//trace("Call: " + id);
					arr = ["js_call", id]; 
				}
				else
				{
					//trace("New: " + id);
					arr = ["js_new", id];
				}
				
				arr = InsertArg(arr, args);
				
				ret = ExternalInterface.call.apply(null, arr);
				return toAS(ret);
			}
		}
		
		
		private static function toAS(val:*):*
		{
			if(val is String)
			{
				switch(val.substr(0, 4))
				{
				case "_OBJ":
					return new JSEnv(+val.substr(4));
					
				case "_FUN":
					return JS_Proxy(+val.substr(4)) as Function;
				}
			}
			
			return val;
		}
		
		
		private static function toJS(val:*):*
		{
			if(val is JSEnv)
			{
				return "_OBJ" + val.obj_id;
			}
			
			if(val is Function)
			{
				FN.push(val);
				return "_FUN" + (FN.length-1);
			}
			
			return val;
		}
		
		
		private var obj_id:int;
		
		public function JSEnv(id:int)
		{
			obj_id = id;
		}
		
		
		override flash_proxy function hasProperty(name:*):Boolean
		{
			//trace("Has: " + name);
			return ExternalInterface.call("js_in", obj_id, name+"");
		}
		
		/**
		 * obj.method(...)
		 */
		override flash_proxy function callProperty(name:*, ... args):*
		{
			//trace("Method: " + name);

			var arr:Array = ["js_method", obj_id, name+""];
			arr = InsertArg(arr, args);
			
			var ret:* = ExternalInterface.call.apply(null, arr);
			return toAS(ret);
		}
		
		/**
		 * X = obj[name]
		 */
		override flash_proxy function getProperty(name:*):*
		{
			//trace("Get: " + name);
			var ret:* = ExternalInterface.call("js_get", obj_id, name+"");
			return toAS(ret);
		}
		
		/**
		 * obj[name] = X
		 */
		override flash_proxy function setProperty(name:*, value:*):void
		{
			//trace("Set: " + name);
			ExternalInterface.call("js_set", obj_id, name+"", toJS(value));
		}
	}
}