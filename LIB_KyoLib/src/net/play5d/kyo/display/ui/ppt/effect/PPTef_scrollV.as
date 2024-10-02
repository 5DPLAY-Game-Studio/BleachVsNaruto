package net.play5d.kyo.display.ui.ppt.effect
{
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class PPTef_scrollV extends BasePPTEffect
	{
		private var _tween:TweenLite;
		public var direct:int = 1;
		
		public function PPTef_scrollV(direct:int=1)
		{
			super();
			this.direct = direct;
		}
		
		protected override function initStart():void{
			_sp.y = 0;
			_currentPic.y = 0;
			
			switch(direct){
				case 1:
					_prevPic.y = -_pointer.size.y;
					_nextPic.y = _pointer.size.y;
					break;
				case -1:
					_prevPic.y = _pointer.size.y;
					_nextPic.y = -_pointer.size.y;
					break;
			}
		}
//		public override function initPrev():void{
//			_prevPic.y = -_pointer.size.y;
//		}
//		public override function initNext():void{
//			_nextPic.y = _pointer.size.y;
//		}
		public override function tweenNext(back:Function):void{
			switch(direct){
				case 1:
					_tween = TweenLite.to(_sp,duration,{y:-_size.y,onComplete:back});
					break;
				case -1:
					_tween = TweenLite.to(_sp,duration,{y:_size.y,onComplete:back});
					break;
			}
		}
		public override function tweenPrev(back:Function):void{
			switch(direct){
				case 1:
					_tween = TweenLite.to(_sp,duration,{y:_size.y,onComplete:back});
					break;
				case -1:
					_tween = TweenLite.to(_sp,duration,{y:-_size.y,onComplete:back});
					break;
			}
		}
		
		public override function tweenBack():void{
			var t:Number = duration / 2;
			_tween = TweenLite.to(_sp,t,{y:0});
		}
		public override function tweening():Boolean{
			return _tween && _tween.active;
		}
		public override function tweenStop():void{
			if(_tween) _tween.kill();
		}
		
		
		protected override function onDraging():void{
			_sp.y = mousePoint().y - _downP.y;
		}
		protected override function dragNext():Boolean{
			return _sp.y - _downSPP.y < -100;
		}
		protected override function dragPrev():Boolean{
			return _sp.y - _downSPP.y > 100;
		}
	}
}