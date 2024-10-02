package net.play5d.kyo.utils
{
	public function superTrace(... args):void
	{
		var e:Error = new Error();
		var caller:String = "[" + e.getStackTrace().match(/[\w\/]*\(\)/g)[1] + "]";
		trace(caller,args);
	}
}