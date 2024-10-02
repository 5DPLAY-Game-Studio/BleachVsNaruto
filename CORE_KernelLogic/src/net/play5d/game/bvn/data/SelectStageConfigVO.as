package net.play5d.game.bvn.data
{
	import flash.geom.Point;

	public class SelectStageConfigVO
	{
		public var x:Number = 0;
		public var y:Number = 0;
		public var width:Number = 800;
		public var height:Number = 600;
		
		public var top:Number = 0;
		public var bottom:Number = 0;
		public var left:Number = 0;
		public var right:Number = 0;
		
//		public var itemGap:Point = new Point(10,10);
		
		public var charList:SelectCharListConfigVO;
		public var assistList:SelectCharListConfigVO;
		
		public var unitSize:Point = new Point(50,50);
		
	//	public var HCount:int; //列数
	//	public var VCount:int; //行数
		
		public function SelectStageConfigVO()
		{
		}
		
		public function setByXML(xml:XML):void{
			
			var layoutXML:Object = xml.stage_setting.layout;
			
			x = Number(layoutXML.@x);
			y = Number(layoutXML.@y);
			width = Number(layoutXML.@width);
			height = Number(layoutXML.@height);
			
			top = Number(layoutXML.@top);
			bottom = Number(layoutXML.@bottom);
			left = Number(layoutXML.@left);
			right = Number(layoutXML.@right);
			
			charList = newListByXML(xml.char_list);
			assistList = newListByXML(xml.assist_list);
			
		}
		
		
		private function newListByXML(xml:XMLList):SelectCharListConfigVO{
			var sv:SelectCharListConfigVO = new SelectCharListConfigVO();
		
			sv.VCount = xml.children().length();
			
			for(var y:int ; y < xml.children().length() ; y++){
				var row:XML = xml.children()[y];
				
				var rowOffset:Point = null;
				var rowOffsetStr:String = row.@offset;
				
				if(rowOffsetStr && rowOffsetStr.length > 0){
					var rowOffsetArr:Array = rowOffsetStr.split(",");
					rowOffset = new Point(rowOffsetArr[0],rowOffsetArr[1]);
				}
				
				if(sv.HCount < row.children().length()) sv.HCount = row.children().length();
				
				for(var x:int = 0 ; x < row.children().length() ; x++){
					var item:XML = row.children()[x];
					
					var moreIds:Array = null;
					var moreIdsStr:String = item.@moreFighter;
					if(moreIdsStr && moreIdsStr.length > 0){
						moreIds = moreIdsStr.split(",");
					}
					
					var fighterID:String = item.toString();
					if(fighterID && fighterID.length < 1) fighterID = null;
					var offset:Point = rowOffset ? rowOffset.clone() : null;
					var offsetStr:String = item.@offset;
					if(offsetStr && offsetStr.length > 0){
						var offsetArr:Array = offsetStr.split(",");
						if(offset){
							offset.x += Number(offsetArr[0]);
							offset.y += Number(offsetArr[1]);
						}else{
							offset = new Point(offsetArr[0],offsetArr[1]);
						}
					}
					
					var cv:SelectCharListItemVO = new SelectCharListItemVO(x,y,fighterID,offset);
					cv.moreFighterIDs = moreIds;
					sv.list.push(cv);
				}
				
			}
			
			return sv;
			
		}
		
	}
}