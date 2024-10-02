package net.play5d.kyo.input
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;
	
	import net.play5d.kyo.utils.KyoUtils;

	public class KyoKeyInput
	{
//		private static var _i:KeyInput;
//		public static function get I():KeyInput{
//			_i ||= new KeyInput();
//			return _i;
//		}
		public var stage:Stage;
		public var orderKeyAble:Boolean = true;
		
		private var _orderKeys:Array = [];
		private var _lastDownTime:int;
		private var _downCodes:Object = {};
		
		public function KyoKeyInput(stage:Stage)
		{
			this.stage = stage;
		}
		
		private var _keys:Object = {};
		private var _map:Object;
		private var _isOn:Boolean;

		private var _downF:Function;
		private var _upF:Function;
		/**
		 * 设置按键映射 
		 * @param array 数组数据格式  ：[{name:String , code:int}] 或 [KyoKeyVO]
		 */
		public function mappingKeyCode(array:Array):void{
			clearMappingKeyCode();
			for each(var i:Object in array){
				addMappingKeyCodeVO(i);
			}
			updateMapping();
		}
		
		/**
		 * 增加按键映射， KyoKeyVO类型
		 * @param o 格式：{name:String , code:int} 或 KyoKeyVO
		 */
		public function addMappingKeyCodeVO(o:Object):void{
			var k:KyoKeyVO;
			if(o is KyoKeyVO){
				k = o as KyoKeyVO;
			}else{
				k = new KyoKeyVO(o.name,o.code);
			}
			_keys[k.name] = k;
			
			updateMapping();
		}
		
		/**
		 * 减少按键映射， KyoKeyVO类型
		 * @param o 格式：String 或 KyoKeyVO
		 */
		public function removeMappingKeyCodeVO(o:Object):void{
			var s:String;
			if(o is String) s = o as String;
			if(o is KyoKeyVO) s = (o as KyoKeyVO).name;
			if(s && _keys[s]){
				delete _keys[s];
				updateMapping();
			}
		}
		
		public function clearMappingKeyCode():void{
			_keys = {};
			_map = {};
		}
		
		/**
		 * 检查按键设置 
		 */
		public function checkOK():Boolean{
			for(var i:String in _keys){
				if(_keys[i] == null) return false;
			}
			return true;
		}
		
		/**
		 * 输出按键设置 
		 */
		public function printKeys():Object{
			var o:Object = {};
			for each(var i:KyoKeyVO in _keys) o[i.name] = i.code;
			return o;
		}
		
		/**
		 *开启按键侦听
		 */
		public function turnOn():void{
			if(_isOn) return;
			_isOn = true;
			if(stage == null) throw new Error('stage 不能为 null');
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyHandler);
		}
		
		private function updateMapping():void{
			_map = {};
			for each(var i:KyoKeyVO in _keys) _map[i.code] = i;
			turnOn();
		}
		
		/**
		 *关闭按键侦听
		 */
		public function turnOff():void{
			_isOn = false;
//			_map = null;
			_orderKeys = [];
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyHandler);
			stage.removeEventListener(KeyboardEvent.KEY_UP,keyHandler);
		}
		
		/**
		 * 根据键位(常量)判断是否按键 :String
		 */
		public function isDownKey(...params):Boolean{
			var isDown:Boolean;
			for each(var i:Object in params){
				var ki:KyoKeyVO = _keys[i] as KyoKeyVO;
				isDown = ki.isDown;
				if(!isDown) return false;
			}
			return isDown;
		}
		/**
		 * 根据按键CODE判断是否按键 
		 */
		public function isDownCode(...params):Boolean{
			var isDown:Boolean;
			for each(var i:Object in params){
				isDown = _downCodes[i] != null;
				if(!isDown) return false;
			}
			return isDown;
		}
		
		/**
		 * 根据键位(常量)判断是否按过键  , String 或 KyoKeyVO
		 */
		public function isPressKey(...params):Boolean{
			var isDown:Boolean = isDownKey.apply(null,params);
			if(isDown){
				for each(var i:Object in params){
					var ki:KyoKeyVO = _keys[i] as KyoKeyVO;
					ki.isDown = false;
				}
			}
			return isDown;
		}
		
		/**
		 * 根据按键CODE判断是否按过键 
		 */
		public function isPressCode(...params):Boolean{
			var isDown:Boolean = isDownCode.apply(null,params);
			if(isDown){
				for each(var i:Object in params){
					delete _downCodes[i];
				}
			}
			return isDown;
		}
		
		/**
		 * 按键回调函数(参数:key常量)
		 * @param down 按下时调用
		 * @param up 松开时调用
		 */
		public function addKeyBack(down:Function , up:Function = null):void{
			_downF = down;
			_upF = up;
		}
		
		/**
		 * 连续按键队列的最大值 
		 */
		public var maxOrderKeyLength:int = 10;
		/**
		 * 连续按键时间限定(毫秒) 
		 */
		public var orderKeyDuration:int = 200;
		/**
		 * 判断是否按顺序按键 
		 * @param params [KyoKeyVO]
		 */
		public function inorder(...params):Boolean{
			var s:int = _orderKeys.length - params.length;
			if(s < 0) return false;
			var l:int = Math.max(_orderKeys.length , params.length);
			for(var i:int = 0 ; i < l ; i++){
				var ok:KyoKeyVO = _orderKeys[s + i];
				var pk:KyoKeyVO = params[i];
				if(pk != ok) return false;
			}
			_orderKeys = [];
			return true;
		}
		public function clearInorder():void{
			_orderKeys = [];
		}
		public function clearDown():void{
			_downCodes = {};
		}
		
		private function keyHandler(e:KeyboardEvent):void{
			var ki:KyoKeyVO;
			
			if(_map) ki = _map[e.keyCode] as KyoKeyVO;
			
			if(e.type == KeyboardEvent.KEY_DOWN){
				if(ki){
					if(!ki.isDown)pushOrder(ki);
					ki.isDown = true;
					if(_downF != null) _downF(ki.name);
				}else{
					if(_downF != null) _downF(e.keyCode);
				}
				_downCodes[e.keyCode] = 1;
			}else{
				if(ki){
					ki.isDown = false;
					if(_upF != null) _upF(ki.name);
				}else{
					if(_upF != null) _upF(e.keyCode);
				}
				delete _downCodes[e.keyCode];
			}
		}
		
		private function pushOrder(k:KyoKeyVO):void{
			if(!orderKeyAble) return;
			if(getTimer() - _lastDownTime > orderKeyDuration){
				_orderKeys = [];
			}
			_lastDownTime = getTimer();
			_orderKeys.push(k);
			if(_orderKeys.length > maxOrderKeyLength) _orderKeys.shift();
		}
		
	}
}