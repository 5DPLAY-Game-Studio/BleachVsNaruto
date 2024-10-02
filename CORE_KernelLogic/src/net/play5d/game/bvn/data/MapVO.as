package net.play5d.game.bvn.data
{
	public class MapVO
	{
		public var id:String;
		public var name:String;
		public var fileUrl:String;
		public var picUrl:String;
		public var bgm:String;
		
		public function MapVO()
		{
		}
		
		public function initByXML(xml:XML):void{
			id = xml.@id;
			name = xml.@name;
			
			fileUrl = xml.file.@url;
			picUrl = xml.img.@url;
			bgm = xml.bgm.@url;
		}
		
	}
}