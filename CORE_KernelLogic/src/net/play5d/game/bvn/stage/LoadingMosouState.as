package net.play5d.game.bvn.stage
{
	import flash.display.DisplayObject;
	import flash.events.DataEvent;

	import net.play5d.game.bvn.GameConfig;
	import net.play5d.game.bvn.MainGame;
	import net.play5d.game.bvn.ctrl.AssetManager;
	import net.play5d.game.bvn.ctrl.GameRender;
	import net.play5d.game.bvn.ctrl.SoundCtrl;
	import net.play5d.game.bvn.ctrl.StateCtrl;
	import net.play5d.game.bvn.ctrl.game_ctrls.GameCtrl;
	import net.play5d.game.bvn.ctrl.game_stage_loader.GameStageLoadCtrl;
	import net.play5d.game.bvn.ctrl.mosou_ctrls.MosouLogic;
	import net.play5d.game.bvn.data.FighterModel;
	import net.play5d.game.bvn.data.GameData;
	import net.play5d.game.bvn.data.MapModel;
	import net.play5d.game.bvn.data.mosou.MosouMissionVO;
	import net.play5d.game.bvn.data.mosou.MosouModel;
	import net.play5d.game.bvn.data.mosou.player.MosouFighterVO;
	import net.play5d.game.bvn.debug.Debugger;
	import net.play5d.game.bvn.events.GameEvent;
	import net.play5d.game.bvn.input.GameInputer;
	import net.play5d.game.bvn.ui.GameUI;
	import net.play5d.game.bvn.utils.ResUtils;
	import net.play5d.kyo.stage.Istage;

	public class LoadingMosouState implements Istage
	{

		private var _ui:loading_fight_mc;
		private var _destoryed:Boolean;
		private var _sltUI:loading_select_ui_mc;

		public function LoadingMosouState()
		{
		}

		public function get display():DisplayObject
		{
			return _ui;
		}

		public function build():void
		{

			GameEvent.dispatchEvent(GameEvent.MOSOU_LOADING_START);

			GameRender.add(render);
			GameInputer.focus();
			GameInputer.enabled = true;

			SoundCtrl.I.BGM(AssetManager.I.getSound('loading'));

			_ui = ResUtils.I.createDisplayObject(ResUtils.swfLib.fight,'loading_fight_mc');
			_sltUI = _ui.sltui;

		}

		private function startLoad():void{
			var maps:Array = [];
			var fighters:Array = [];
			var assisters:Array = null;
			var bgms:Array = [];

			var mission:MosouMissionVO = MosouModel.I.currentMission;

			maps.push(mission.map);

			var fvos:Vector.<MosouFighterVO> = GameData.I.mosouData.getFighterTeam();
			for(var i:int; i < fvos.length; i++){
				fighters.push(fvos[i].id);
			}

			var enemyIds:Array = mission.getAllEnemieIds();
			fighters = fighters.concat(enemyIds);

			var bossIds:Array = mission.getBossIds();

			bgms.push(mission.map, fighters[0], bossIds);
			bgms.push('boss_naruto', 'boss_bleach');

			GameStageLoadCtrl.I.init(onLoadProcess, onLoadError);
			GameStageLoadCtrl.I.loadGame(maps, fighters, assisters, bgms, onLoadFinish);
		}

		private function onLoadProcess(msg:String, process:Number):void{
			_sltUI.bar.txt.text = msg;
			_sltUI.bar.bar.scaleX = process;

			GameEvent.dispatchEvent(GameEvent.MOSOU_LOADING, {msg: msg, process:process});
		}

		private function onLoadError(msg:String):void{
			Debugger.errorMsg(msg);
		}

		private function onLoadFinish():void{
//			trace("onLoadFinish");
//			return;

			initGameRunData();
			StateCtrl.I.transIn(MainGame.I.goMosouGame , false);

			GameEvent.dispatchEvent(GameEvent.MOSOU_LOADING_FINISH);
		}

		private function render():void{
			if(GameInputer.back(1)){
				if(GameUI.showingDialog()){
					GameUI.cancelConfrim();
				}else{
					GameUI.confrim('BACK TITLE?',"返回到主菜单？",MainGame.I.goMenu);
					GameEvent.dispatchEvent(GameEvent.CONFRIM_BACK_MENU);
				}
			}
		}

		private function initGameRunData():void{
			var mission:MosouMissionVO = MosouModel.I.currentMission;

			GameCtrl.I.initMosouGame();

			GameCtrl.I.getMosouCtrl().gameRunData.koNum = 0;
			MosouLogic.I.clearHits();
			GameCtrl.I.getMosouCtrl().gameRunData.gameTimeMax = mission.time * GameConfig.FPS_ANIMATE;
			GameCtrl.I.getMosouCtrl().gameRunData.gameTime = mission.time * GameConfig.FPS_ANIMATE;
//			GameCtrl.I.getMosouCtrl().gameRunData.gameTime = 30 * GameConfig.FPS_ANIMATE;

			var fighterTeam:Vector.<MosouFighterVO> = GameData.I.mosouData.getFighterTeam();

			GameCtrl.I.gameRunData.p1FighterGroup.fighter1 = FighterModel.I.getFighter(fighterTeam[0].id);
			GameCtrl.I.gameRunData.p1FighterGroup.fighter2 = FighterModel.I.getFighter(fighterTeam[1].id);
			GameCtrl.I.gameRunData.p1FighterGroup.fighter3 = FighterModel.I.getFighter(fighterTeam[2].id);

			GameCtrl.I.gameRunData.map = MapModel.I.getMap(mission.map);

		}

		public function afterBuild():void
		{
			StateCtrl.I.transOut(startLoad);
		}

		public function destory(back:Function=null):void
		{
			_destoryed = true;

			SoundCtrl.I.BGM(null);

			GameInputer.clearInput();
			GameRender.remove(render);

			GameUI.closeConfrim();
		}
	}
}
