package net.play5d.kyo.display.ui
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import net.play5d.kyo.display.ui.IphoneIconList;
	import net.play5d.kyo.display.ui.KyoTileList;
	import net.play5d.kyo.utils.KyoAlign;
	
	public class IphoneIconListDoc extends Sprite
	{
		private var _iplist:IphoneIconList;
		private var _docClass:Class;
		public var gap:Point = new Point(20,0);
		public function IphoneIconListDoc(docClass:Class , list:IphoneIconList)
		{
			super();
			_docClass = docClass;
			_iplist = list;
			_iplist.addEventListener(IphoneIconListEvent.PAGE_CHANGE,update);
			update();
		}
		
		private var _list:KyoTileList;
		public function update(...params):void{
			var current:int = _iplist.curPage;
			var total:int = _iplist.totalPage;
			
			var ds:Array = [];
			for(var i:int ; i < total ; i++){
				var c:MovieClip = new _docClass();
				c.pg = i+1;
				c.gotoAndStop((i+1 == current) ? 1 : 2);
				c.addEventListener(MouseEvent.CLICK,onccclick);
				ds.push(c);
			}
			if(!_list){
				_list = new KyoTileList();
				_list.unitySize = new Point(11,11);
				_list.lockSize = true;
				_list.gap = gap;
				addChild(_list);
			}
			_list.setDisplays(ds);
			
			_list.x = 0;
			KyoAlign.centerW(_list,_iplist.touchSize.x);
		}
		
		private function onccclick(e:MouseEvent):void{
			var c:MovieClip = e.currentTarget as MovieClip;
			_iplist.goPage(c.pg);
//			trace(c.pg);
		}
		
		public function destory():void{
			if(_iplist) _iplist.removeEventListener(IphoneIconListEvent.PAGE_CHANGE,update);
			if(_list) _list.removeAllChildren();
		}
		
	}
}