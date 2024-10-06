package net.play5d.game.bvn.stage
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.GameRender;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.ctrl.StateCtrl;
	import net.play5d.game.bvn.ctrl.mosou_ctrls.MosouLogic;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.mosou.MosouModel;
	import net.play5d.game.bvn.data.mosou.MosouWorldMapAreaVO;
	import net.play5d.game.bvn.data.mosou.MosouWorldMapVO;
	import net.play5d.game.bvn.events.GameEvent;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.ui.bigmap.BigmapClould;
	import net.play5d.game.bvn.ui.bigmap.WorldMapPointUI;
	import net.play5d.game.bvn.ui.dialog.DialogManager;
	import net.play5d.game.bvn.utils.BtnUtils;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.game.bvn.utils.TouchMoveEvent;
	import net.play5d.game.bvn.utils.TouchUtils;
	import net.play5d.kyo.stage.Istage;

	public class WorldMapState implements Istage
	{
		private var _ui:Sprite;
		private var _mapUI:Sprite;

		private var _viewMc:Sprite;
		private var _pointMc:Sprite;
		private var _maskMc:Sprite;
		private var _bgMc:Sprite;

		private var _pointUIs:Vector.<WorldMapPointUI>;

		private var _downUIPos:Point = new Point();
		private var _downMousePos:Point = new Point();

		private var _scale:Number = 1;
		private var _position:Point = new Point();
		private var _currentPoint:WorldMapPointUI;

		private var _cloudUI:BigmapClould;

		private var _backBtn:DisplayObject;

		public function WorldMapState()
		{
		}

		public function get display():DisplayObject
		{
			return _ui;
		}

		public function build():void
		{
			_ui = new Sprite();

			_mapUI = ResUtils.I.createDisplayObject(ResUtils.swfLib.bigMap, ResUtils.BIG_MAP);
			_ui.addChild(_mapUI);

			_viewMc = _mapUI.getChildByName("view_mc") as Sprite;
			_pointMc = _mapUI.getChildByName("point_mc") as Sprite;
			_maskMc = _mapUI.getChildByName("mask_mc") as Sprite;
			_bgMc = _mapUI.getChildByName("bg_mc") as Sprite;

			_backBtn = ResUtils.I.createDisplayObject(ResUtils.swfLib.dialog, 'backbtn_btn');
			if(_backBtn){
				_backBtn.x = _backBtn.y = 10;
				BtnUtils.initBtn(_backBtn, backHandler);
				_ui.addChild(_backBtn);
			}

			_viewMc.mask = _maskMc;
			_viewMc.cacheAsBitmap = true;
			_maskMc.cacheAsBitmap = true;

			MosouLogic.I.updateMapAreas();

			initPointUIs();

			_cloudUI = new BigmapClould(_mapUI.getBounds(_mapUI));
			_ui.addChild(_cloudUI);

			_cloudUI.init();

			StateCtrl.I.transOut();

			GameEvent.addEventListener(GameEvent.MOSOU_FIGHTER_UPDATE, updatePointsUI);

			GameRender.add(render, this);

			SoundCtrl.I.BGM(AssetManager.I.getSound('back'));


		}

		private function render():void{
			_cloudUI.render();
		}

		private function updatePointsUI(e:GameEvent = null):void{
			for each(var p:WorldMapPointUI in _pointUIs){
				p.update();
			}
		}

		private function initPointUIs():void{
			var i:int, d:DisplayObject;

			var pointMap:Object = {};
			var maskMap:Object = {};

			for(i=0; i < _pointMc.numChildren; i++){
				d = _pointMc.getChildAt(i);
				if(d == null) continue;
				pointMap[d.name] = d;
				d.visible = false;
			}

			for(i=0; i < _maskMc.numChildren; i++){
				d = _maskMc.getChildAt(i);
				if(d == null) continue;
				maskMap[d.name] = d;
				d.visible = false;
			}

			_pointUIs = new Vector.<WorldMapPointUI>();

			var map:MosouWorldMapVO = MosouModel.I.getMap(GameData.I.mosouData.getCurrentMap().id);
			var datas:Vector.<MosouWorldMapAreaVO> = map.areas;
			for each(var m:MosouWorldMapAreaVO in datas){
				if(!pointMap[m.id]) continue;

				var ui:WorldMapPointUI = new WorldMapPointUI(pointMap[m.id], maskMap[m.id], m);
				ui.addEventListener(WorldMapPointUI.EVENT_SELECT, onSelectPoint);
				_pointUIs.push(ui);
			}

		}


		private function onSelectPoint(e:Event):void{
			var p:WorldMapPointUI = e.currentTarget as WorldMapPointUI;
			var data:MosouWorldMapAreaVO = p.data;

			if(data.building()){
				GameUI.alert('NOT OPEN', '暂未开放');
				return;
			}

			GameEvent.dispatchEvent(GameEvent.MOSOU_MAP);

			if(MosouLogic.I.checkCurrentArea(data.id)){
				gotoMission(data);
			}else{
				GameData.I.mosouData.setCurrentArea(data.id);
				updatePointsUI();
			}

		}

		private function gotoMission(data:MosouWorldMapAreaVO):void{
			var allFinish:Boolean = MosouLogic.I.getAreaPercent(data.id) >= 1;
			var txt:String = allFinish ? '已通过全部关卡，是否进入最后一关？' : '进入下一关？';
			GameUI.confrim('CONFRIM', txt, function():void{
				MosouModel.I.currentMission = MosouLogic.I.getNextMission(data);
				StateCtrl.I.transIn(MainGame.I.loadGame, true);
//				MainGame.I.loadGame();
			});

			GameEvent.dispatchEvent(GameEvent.CONFRIM_MOSOU_NEXT_MISSION);
		}

		private function focusCurrentPoint():void{
			var current:WorldMapPointUI;
			for each(var i:WorldMapPointUI in _pointUIs){
				if(MosouLogic.I.checkCurrentArea(i.data.id)){
					current = i;
					break;
				}
			}

			if(!current) return;

			_currentPoint = current;

			var center:Point = new Point(GameConfig.GAME_SIZE.x / 2, GameConfig.GAME_SIZE.y / 2);

			_scale = 1.5;
			_position.x = center.x - ( current.getPosition().x * _scale );
			_position.y = center.y - ( current.getPosition().y * _scale );
			renderPosAndSize();
		}

		public function afterBuild():void
		{
			initDrag();
			focusCurrentPoint();
		}

		private function initDrag():void{
			if(GameConfig.TOUCH_MODE){
				TouchUtils.I.listenOneFinger(MainGame.I.stage, touchMoveHandler);
				TouchUtils.I.listenTwoFinger(MainGame.I.stage, touchZoomHandler);
			}else{
				MainGame.I.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
				MainGame.I.stage.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
				MainGame.I.stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseHandler);
			}

		}

		private function touchMoveHandler(e:TouchMoveEvent):void{
			if(e.type == TouchMoveEvent.TOUCH_MOVE){
				_position.x += e.deltaX;
				_position.y += e.deltaY;
				renderPosAndSize();
			}
		}

		private function touchZoomHandler(e:TouchMoveEvent):void{
			if(e.type == TouchMoveEvent.TOUCH_MOVE){
				_scale += e.delta;
				renderPosAndSize(true);
			}
		}

		private function mouseHandler(e:MouseEvent):void{

			if(DialogManager.showingDialog()) return;

			switch(e.type){
				case MouseEvent.MOUSE_DOWN:
					_downUIPos.x = _position.x;
					_downUIPos.y = _position.y;

					_downMousePos.x = MainGame.I.stage.mouseX;
					_downMousePos.y = MainGame.I.stage.mouseY;

					_mapUI.removeEventListener(Event.ENTER_FRAME, renderDrag);
					_mapUI.addEventListener(Event.ENTER_FRAME, renderDrag);
					break;
				case MouseEvent.MOUSE_UP:
					_mapUI.removeEventListener(Event.ENTER_FRAME, renderDrag);
					break;
				case MouseEvent.MOUSE_WHEEL:
					if(e.delta < 0){
						_scale -= 0.1;
					}else{
						_scale += 0.1;
					}
					renderPosAndSize(true);
					break;
			}
		}

		private function renderDrag(e:Event):void{
			_position.x = MainGame.I.stage.mouseX - _downMousePos.x + _downUIPos.x;
			_position.y = MainGame.I.stage.mouseY - _downMousePos.y + _downUIPos.y;
			renderPosAndSize();
		}

		private function renderPosAndSize(setZommInCenter:Boolean = false):void{

			if(_scale < 1) _scale = 1;
			if(_scale > 2) _scale = 2;

			if(setZommInCenter && _currentPoint){
				var scaleOffset:Number = _mapUI.scaleX - _scale;
				if(scaleOffset != 0){
//					_position.x += GameConfig.GAME_SIZE.x * scaleOffset / 2;
//					_position.y += GameConfig.GAME_SIZE.y * scaleOffset / 2;
					_position.x += _currentPoint.getPosition().x * scaleOffset;
					_position.y += _currentPoint.getPosition().y * scaleOffset
				}
			}

			var l:Number = GameConfig.GAME_SIZE.x - _bgMc.width * _scale;
			var t:Number = GameConfig.GAME_SIZE.y - _bgMc.height * _scale;

			if(_position.x > 0) _position.x = 0;
			if(_position.y > 0) _position.y = 0;
			if(_position.x < l) _position.x = l;
			if(_position.y < t) _position.y = t;

			_mapUI.scaleX = _mapUI.scaleY = _scale;
			_mapUI.x = _position.x;
			_mapUI.y = _position.y;

			_cloudUI.scaleX = _cloudUI.scaleY = _scale * 0.8;
			_cloudUI.x = _position.x * 0.8;
			_cloudUI.y = _position.y * 0.8;
		}

		private function backHandler(...params):void{
			GameUI.confrim('EXIT', '返回到游戏主菜单？', MainGame.I.goMenu);
			GameEvent.dispatchEvent(GameEvent.CONFRIM_BACK_MENU);
		}

		public function destory(back:Function=null):void
		{
			GameRender.remove(render, this);

			TouchUtils.I.unlistenOneFinger(MainGame.I.stage);
			TouchUtils.I.unlistenTwoFinger(MainGame.I.stage);

			MainGame.I.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
			MainGame.I.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler);
			MainGame.I.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseHandler);

			GameEvent.removeEventListener(GameEvent.MOSOU_FIGHTER_UPDATE, updatePointsUI);

			if(_backBtn){
				BtnUtils.destoryBtn(_backBtn);
				_backBtn = null;
			}

			if(_cloudUI){
				_cloudUI.destory();
				_cloudUI = null;
			}

			if(_pointUIs){
				for each(var p:WorldMapPointUI in _pointUIs){
					p.destory();
				}
				_pointUIs = null;
			}

			if(_mapUI){
				try{
					_ui.removeChild(_mapUI);
				}catch(e:Error){}
				_mapUI = null;
			}

		}




	}
}