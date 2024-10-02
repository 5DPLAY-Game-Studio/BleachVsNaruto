package net.play5d.kyo.display.ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class TabBox extends BaseBox
	{
		private var _lx:Number;
		private var _ly:Number;
		
		public var selectedTab:ITab;
		public function get selectedIndex():int{
			return _instances.indexOf(selectedTab);
		}
		public function TabBox(gapX:Number = 5 , gapY:Number = 0)
		{
			this.gapX = gapX;
			this.gapY = gapY;
		}
		
		protected override function build():void{
			_lx = _ly = 0;
			if(!_instances || _instances.length < 1) return;
			update();
			select(0);
		}
		
		protected override function buildByRepeater():void{
			if(repeater)_instances = repeater.getItems();
			build();
		}
		
		public function update():void{
			var e:int = numChildren > _instances.length ? numChildren : _instances.length;
			for(var i:int ; i < e ; i++){
				var dc:DisplayObject
				try{
					dc = getChildAt(i);
				}catch(e:Error){
					dc = null;
				}
				var t:ITab = _instances[i];
				if(t && !dc)addChildItem(t);
				if(!t && dc){
					removeChild(dc);
					dc = null;
				}
			}
		}
		
		private function addChildItem(d:ITab):void{
			var dp:DisplayObject;
			if(d is DisplayObject){
				dp = d as DisplayObject;
			}else{
				dp = d.display;
			}
			dp.x = _lx;
			dp.y = _ly;
			addChild(dp);
			d.addEventListener(MouseEvent.CLICK,mouseHandler,false,0,true);
			if(gapX > 0) _lx += dp.width + gapX;
			if(gapY > 0) _ly += dp.height + gapY;
		}
		
		private function mouseHandler(e:MouseEvent):void{
			selectTab(e.currentTarget as ITab);
			dispatchEvent(new Event(Event.SELECT));
		}
		
		private function selectTab(v:ITab):void{
			selectedTab = v;
			if(v.selected == true) return;
			for each(var i:ITab in _instances)i.selected = false;
			v.selected = true;
		}
		
		public function select(id:int):void{
			if(_instances)selectTab(_instances[id]);
		}
		
		
	}
}