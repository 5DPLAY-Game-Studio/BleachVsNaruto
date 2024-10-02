package net.play5d.game.bvn.ui.dialog
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.MainGame;

	public class DialogManager
	{
		private static var _dialogBG:Sprite;
		private static var _showingDialogs:Vector.<BaseDialog> = new Vector.<BaseDialog>();
		public function DialogManager()
		{
		}
		
		public static function showingDialog():Boolean{
			return _showingDialogs.length > 0;
		}
		
		private static function addDialogBg():void{
			if(!_dialogBG){
				var bp:BitmapData = new BitmapData(1, 1, false, 0);
				_dialogBG = new Sprite();
				_dialogBG.graphics.beginBitmapFill(bp, null, true, false);
				_dialogBG.graphics.drawRect(0, 0, GameConfig.GAME_SIZE.x, GameConfig.GAME_SIZE.y);
				_dialogBG.graphics.endFill();
				_dialogBG.alpha = 0.7;
			}
			MainGame.I.root.addChild(_dialogBG);
		}
		
		public static function showDialog(v:BaseDialog, hideOthers:Boolean = true):void{
			if(hideOthers && _showingDialogs.length > 0){
				for each(var d:BaseDialog in _showingDialogs){
					d.hide();
				}
			}else{
				addDialogBg();
			}
			
			var x:Number = (v.width > 0) ? (GameConfig.GAME_SIZE.x - v.width) / 2 : 0;
			var y:Number = (v.height > 0) ? (GameConfig.GAME_SIZE.y - v.height) / 2 : 0;
			v.show(x, y);
			
			fadIn(v);
			
			_showingDialogs.push(v);
		}
		
		public static function closeDialog(v:BaseDialog):void{
			fadOut(v, tweenBack);
			
			function tweenBack():void{
				var index:int = _showingDialogs.indexOf(v);
				if(index != -1) _showingDialogs.splice(index, 1);
				
				if(_showingDialogs.length < 1){
					try{
						MainGame.I.root.removeChild(_dialogBG);
					}catch(e:Error){}
				}else{
					var last:BaseDialog = _showingDialogs[_showingDialogs.length - 1];
					if(last.hiding()) last.resume();
					
					addDialogBg();
					fadIn(last);
				}
			}
			
			
		}
		
		private static function fadIn(d:BaseDialog, back:Function = null):void{
			var view:DisplayObject = d.getDisplay();
			
			var y:Number = view.y;
			view.alpha = 0;
			view.y -= 10;
			
			MainGame.I.root.addChild(d.getDisplay());
			
			TweenLite.to(view, 0.3, {y: y, alpha: 1, onComplete: function():void{
				d.init();
				if(back != null) back();
			}});
		}
		
		private static function fadOut(d:BaseDialog, back:Function):void{
			var view:DisplayObject = d.getDisplay();
			TweenLite.to(view, 0.2, { y: view.y - 10, alpha: 0, onComplete: function():void{
				d.close();
				d.destory();
				try{
					MainGame.I.root.removeChild(d.getDisplay());
				}catch(e:Error){}
				
//				if(back != null) back();
			} });
			if(back != null) back();
		}
		
	}
}