package net.play5d.game.bvn.ui.bigmap
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import net.play5d.game.bvn.GameConfig;
	
	public class BigmapClould extends Sprite
	{
		private var _clouds:Vector.<CloudView> = new Vector.<CloudView>();
		private var _createFrame:int;
		private var _bounds:Rectangle;
		
		public function BigmapClould(bounds:Rectangle)
		{
			super();
			_bounds = bounds;
			mouseChildren = mouseEnabled = false;
		}
		
		public function init():void{
			for(var i:int = _bounds.y + 100; i < _bounds.height; i+= 50){
				addCloud(getRandomX() , i);
			}
		}
		
		public function destory():void{
			if(_clouds){
				for each(var i:CloudView in _clouds){
					try{
						this.removeChild(i.mc);
					}catch(e:Error){}
				}
				_clouds = null;
			}
		}
		
		public function render():void{
			for each(var i:CloudView in _clouds){
				if(i.render()){
					try{
						trace('remove cloud');
						var index:int = _clouds.indexOf(i);
						if(index != -1) _clouds.splice(_clouds.indexOf(i), 1);
						this.removeChild(i.mc);
					}catch(e:Error){
						trace('BigmapClould', e);
					}
				}
			}
			
			if(--_createFrame < 0){
				addCloud();
				_createFrame = 5 * GameConfig.FPS_UI;
			}
		}
		
		private function addCloud(X:Number = 0, Y:Number = 0):void{
			if(X == 0) X = getRandomX();
			if(Y == 0) Y = _bounds.y + _bounds.height + 100;
			
			var v:CloudView = new CloudView(X, Y);
			this.addChild(v.mc);
			_clouds.push(v);
		}
		
		private function getRandomX():Number{
			return _bounds.x + ( (_bounds.width / 20) * (Math.random() * 20) ) - 100;
		}
		
//		private function getRandomY():Number{
//			return _bounds.y + ( (_bounds.height / 20) * (Math.random() * 20) );
//		}
		
	}
}