package net.play5d.game.bvn.data
{
	//import net.play5d.game.bvn.data.mosou.MosouWaveRunVO;
	import net.play5d.game.bvn.data.mosou.MosouWaveVO;
	import net.play5d.game.bvn.fighter.FighterMain;
	import net.play5d.game.bvn.map.MapMain;

	/**
	 * 记录运行游戏时需要的相关数据
	 */
	public class GameRunDataVO
	{

		public const p1FighterGroup:GameRunFighterGroup = new GameRunFighterGroup();
		public const p2FighterGroup:GameRunFighterGroup = new GameRunFighterGroup();
		public var map:MapVO;

		public var p1Wins:int = 0;
		public var p2Wins:int = 0;

		public var lastWinnerTeam:TeamVO;

		public var continueLoser:FighterMain;

		public var lastWinner:FighterMain;
		public var lastWinnerHp:int = 1000;

		public var lastLoserData:FighterVO;
		public var lastLoserQi:int = 0;

		public var round:int = 1;

		public var gameTime:int;
		public var gameTimeMax:int; //-1时，无限时

		public var isTimerOver:Boolean;
		public var isDrawGame:Boolean;

//		public var winner:FighterMain;
//		public var loser:FighterMain;

		public function GameRunDataVO()
		{
		}

		public function getWins(f:FighterMain):int{
			switch(f.team.id){
				case 1:
					return p1Wins;
					break;
				case 2:
					return p2Wins;
					break;
			}
			return 0;
		}

		public function reset():void{
			p1Wins = 0;
			p2Wins = 0;
			round = 1;

			lastWinnerTeam = null;
			lastWinner = null;

			lastLoserData = null;
			lastLoserQi = 0;

			isTimerOver = false;
			isDrawGame = false;

			lastWinnerHp = GameData.I.config.fighterHP;

			gameTimeMax = GameData.I.config.fightTime;
			gameTime = gameTimeMax;

			continueLoser = null;

		}

		public function clear():void{
			map = null;
			lastWinnerTeam = null;
			lastWinner = null;
			lastLoserData = null;
			continueLoser = null;
		}

		public function nextRound():void{
			round ++;
			gameTime = gameTimeMax;
			isTimerOver = false;
//			lastWinner = null;
		}

		public function setAllowLoseHP(v:Boolean):void{
			if(p1FighterGroup && p1FighterGroup.currentFighter) p1FighterGroup.currentFighter.isAllowLoseHP = v;
			if(p2FighterGroup && p2FighterGroup.currentFighter) p2FighterGroup.currentFighter.isAllowLoseHP = v;
		}

	}
}
