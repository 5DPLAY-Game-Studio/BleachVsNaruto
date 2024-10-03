package net.play5d.game.bvn.win.utils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import net.play5d.game.bvn.interfaces.ILoger;

	public class Loger implements ILoger
	{
		private static var _file:File;
		private static var _fileStream:FileStream;
		
		public function Loger()
		{
		}
		
		public function log(v:String):void{
			
			trace(v);
			
			if(!_file){
				_file = new File(File.applicationDirectory.nativePath+"/log.log");
			}
			_fileStream = new FileStream();
			_fileStream.open(_file,FileMode.APPEND);
			_fileStream.writeUTFBytes(v+"\r\n");
			_fileStream.close();
			_fileStream = null;
		}
		
	}
}