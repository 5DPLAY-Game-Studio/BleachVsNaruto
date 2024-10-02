package net.play5d.game.bvn.interfaces
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	
	import net.play5d.game.bvn.data.ConfigVO;
	import net.play5d.game.bvn.input.IGameInput;

	public interface IGameInterface
	{
		function initTitleUI(ui:DisplayObject):void;
		/**
		 * 更多游戏 
		 */
		function moreGames():void;
		/**
		 * 打开排行榜 
		 */
		function showRank():void;
		/**
		 * 上传分数 
		 * @param score
		 */
		function submitScore(score:int):void;
		
		/**
		 * 保存 
		 * @param data
		 */
		function saveGame(data:Object):void;
		/**
		 * 读取 
		 * @return 
		 */
		function loadGame():Object;
		
		/**
		 * 游戏输入接口
		 * @param type 输入类型，对应类：net.play5d.game.bvn.input.GameInputType
		 * @return 
		 */
		function getGameInput(type:String):Vector.<IGameInput>;
		
//		/**
//		 * 操作接口 
//		 * @param player
//		 * @return 
//		 */
//		function getFighterCtrl(player:int):IFighterActionCtrl;
		
		/**
		 * 游戏菜单
		 * @return [{txt:英文名,cn:中文名称,(func:回调函数),children:[{txt:英文名,cn:中文名称,func:回调函数}]}] , 返回NULL时使用默认菜单
		 */
		function getGameMenu():Array;
		/**
		 * 设置菜单 
		 * @return [{txt:"英文名",cn:"中文名",options:[{label:'英文选项名',cn:'中文选项名',value:值}],optoinKey:'对应configVO的属性名（可自定义，但不能和之前定义的属性名称重复！）'}]
		 */
		function getSettingMenu():Array;
		
		
		/**
		 * 更新输入设置 ，如果使用默认，返回FALSE
		 */
		function updateInputConfig():Boolean;
		
		/**
		 * 扩展设置项 
		 * @return {key:value}
		 */
		function getConfigExtend():IExtendConfig;
		
		function afterBuildGame():void;
		
		function applyConfig(config:ConfigVO):void;
		
		/**
		 * 制作群界面 
		 */
		function getCreadits(creditsInfo:String):Sprite;
		
		/**
		 * 校验文件
		 */
		function checkFile(url:String, file:ByteArray):Boolean;
		
		/**
		 * 增加无双的钱
		 */
		function addMosouMoney(back:Function):void;
		
	}
}