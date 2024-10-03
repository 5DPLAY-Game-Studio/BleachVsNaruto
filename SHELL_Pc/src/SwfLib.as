package
{
	import net.play5d.game.bvn.interfaces.ISwfLib;

	public class SwfLib implements ISwfLib
	{

		[Embed(source="/../../shared/swf/common_ui.swf")]
		private var _common_ui:Class;

		[Embed(source="/../../shared/swf/fight.swf")]
		private var _fight:Class;

		[Embed(source="/../../shared/swf/gameover.swf")]
		private var _gameover:Class;

		[Embed(source="/../../shared/swf/howtoplay.swf")]
		private var _howtoplay:Class;

		[Embed(source="/../../shared/swf/loading.swf")]
		private var _loading:Class;

		[Embed(source="/../../shared/swf/select.swf")]
		private var _select:Class;

		[Embed(source="/../../shared/swf/setting.swf")]
		private var _setting:Class;

		[Embed(source="/../../shared/swf/title.swf")]
		private var _title:Class;

		[Embed(source="/../../shared/swf/mosou.swf")]
		private var _mosou:Class;

		[Embed(source="/../../shared/swf/bigmap.swf")]
		private var _bigMap:Class;

		[Embed(source="/../../shared/swf/dialog_ui.swf")]
		private var _dialog:Class;

		public function SwfLib()
		{
		}

		public function get common_ui():Class{
			return _common_ui;
		}

		public function get fight():Class
		{
			return _fight;
		}

		public function get gameover():Class
		{
			return _gameover;
		}

		public function get howtoplay():Class
		{
			return _howtoplay;
		}

		public function get loading():Class
		{
			return _loading;
		}

		public function get select():Class
		{
			return _select;
		}

		public function get setting():Class
		{
			return _setting;
		}

		public function get title():Class
		{
			return _title;
		}

		public function get mosou():Class
		{
			return _mosou;
		}

		public function get bigMap():Class
		{
			return _bigMap;
		}

		public function get dialog():Class
		{
			return _dialog;
		}

	}
}
