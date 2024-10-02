package net.play5d.kyo.utils
{
	import com.adobe.utils.StringUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class KyoUtils
	{
		/**
		 * 根据子元素属性查找一个对象
		 * @param array
		 * @param matchKey
		 * @param matchValue
		 * @return 
		 */
		public static function array_findOneByPortal(array:Array,matchKey:*,matchValue:*):*{
			for each(var i:* in array){
				if(i[matchKey] == matchValue) return i;
			}
			return null;
		}
		/**
		 * 根据子元素属性删除对象
		 * @param array
		 * @param matchKey
		 * @param matchValue
		 * 
		 */
		public static function array_removeByPortal(array:Array,matchKey:*,matchValue:*):void{
			for(var i:int ; i < array.length ; i++){
				var m:* = array[i];
				if(m[matchKey] == matchValue) array.splice(i,1);
			}
		}
		/**
		 * 根据子元素属性查找所有符合的对象
		 * @param array
		 * @param matchKey
		 * @param matchValue
		 * @return 
		 */
		public static function array_findAllByPortal(array:Array,matchKey:*,matchValue:*):*{
			var r:Array = [];
			for each(var i:* in array){
				if(i[matchKey] == matchValue) r.push(i);
			}
			return r;
		}
		/**
		 * 数组中是否存在对象 
		 */
		public static function array_hasItem(array:Array , item:*):Boolean{
			var i:int = array.indexOf(item);
			return i != -1;
		}
		
		/**
		 * 插入不存在的对象到数组中 
		 */
		public static function array_push_notHas(array:Array , item:*):Boolean{
			if(item == null) return false;
			var i:int = array.indexOf(item);
			if(i == -1){
				array.push(item);
				return true;
			}else{
				return false;
			}
		}
		
		/**
		 * 将对象插入到指定的index中 
		 * @param array
		 * @param item 一个或多个对象，多个对象时为Array类型
		 * @param index
		 * 
		 */
		public static function array_pushAt(array:Array , item:* , index:int):void{
			var items:Array;
			if(item is Array){
				items = item as Array;
			}else{
				items = [item];
			}
			
			for(var i:int = array.length ; i > index ; i--){
				var ii:int = i + (items.length - 1);
				array[ii] = array[i-1];
			}
			
			for(var j:int = 0 ; j < items.length ; j++){
				array[index + j] = items[j];
			}
		}
		
		/**
		 * 从数组中删除对象 
		 */
		public static function array_removeItem(array:Object , item:*):void{
			var i:int = array.indexOf(item);
			if(i != -1) array.splice(i,1);
		}
		
		/**
		 * 删除数组中的重复对象 
		 */
		public static function array_deleteSames(array:Object):void{
			var ba:Object = array.concat();
			
			array.splice(0,array.length);
			
			for(var i:int = 0; i < ba.length; i++) {
				var o:Object = ba[i];
				if (array.indexOf(o) == -1) {
					array.push(o);
				}
			}
		}
		
		public static function array_countItem(array:Object , item:*):int{
			var n:int;
			for(var i:int = 0; i < array.length; i++) {
				if (array[i] == item) n++;
			}
			return n;
		}
		
		public static function sprite_removeAllChildren(sp:Sprite):void{
			while(sp.numChildren > 0){
				sp.removeChildAt(0);
			}
		}
		
		public static function array_fixID(array:Array):Array{
			var a:Array = [];
			for each(var i:* in array){
				a.push(i);
			}
			return a;
		}
		
		/**
		 * 获取属性相同的数据 
		 * @param array
		 * @param key 属性K值
		 */
		public static function array_getSamePortalItems(array:Array , key:String):Array{
			var vo:Object={};
			var vs:Object = {};
			
			for each(var i:* in array){
				var v:* = i[key];
				if(vo[v]){
					vs[v] = 1;
				}else{
					vo[v] = 1;
				}
			}
			var r:Array = [];
			for(var j:String in vs){
				for each(i in array){
					if(i[key] == j) r.push(i);
				}
			}
			return r;
		}
		
		public static function array_groupByPortal(array:Array , key:String):Object{
			var o:Object = {};
			for each(var i:* in array){
				var v:* = i[key];
				o[v] ||= [];
				(o[v] as Array).push(i);
			}
			return o;
		}
		
		/**
		 * 获取MC的所有帧的绘制位图 
		 */
		public static function getBitmapDatasByMC(mc:DisplayObject):Array{
			var a:Array = [];
			var bd:BitmapData;
			if(mc is MovieClip){
				var mmc:MovieClip = mc as MovieClip;
				for(var i:int ; i < mmc.totalFrames ; i++){
					mmc.gotoAndStop(i);
					bd = new BitmapData(mmc.width,mmc.height,true,0);
					bd.draw(mmc);
					a.push(bd);
				}
			}else{
				bd = new BitmapData(mc.width,mc.height,true,0);
				bd.draw(mc);
				a.push(bd);
			}
			return a;
		}
		
		/**
		 * 绘制图形对象 
		 * @param d 图形对象 
		 * @param fixPosition 根据注册点位置调节
		 */
		public static function drawDisplay(d:DisplayObject , fixPosition:Boolean = true ,  transparent:Boolean=true, fillColor:uint=0 , colorTransform:ColorTransform = null):Bitmap{
			if(!d || d.width <= 0 || d.height <= 0) return null;
			var bp:Bitmap = new Bitmap(new BitmapData(d.width,d.height,transparent,fillColor));
			var matrix:Matrix;
			if(fixPosition){
				var bds:Rectangle = d.getBounds(d);
				matrix = new Matrix(1,0,0,1,-bds.x,-bds.y);
			}
			bp.bitmapData.draw(d,matrix,colorTransform);
			return bp;
		}
		
		/**
		 * 绘制图形滤镜 
		 * @param d 图形对象 
		 * @param filter 滤镜对象
		 * @param fixPosition 根据注册点位置调节
		 * @param filterOffset 绘制大小调节
		 * @return 
		 */
		public static function drawBitmapFilter(d:DisplayObject, filter:BitmapFilter, fixPosition:Boolean = true, filterOffset:Point = null):BitmapData{
			var bpd:BitmapData = new BitmapData(d.width, d.height, true, 0);
			
			var matrix:Matrix;
			if(fixPosition){
				var bds:Rectangle = d.getBounds(d);
				matrix = new Matrix(1,0,0,1,-bds.x,-bds.y);
			}
			
			bpd.draw(d, matrix);
			
			var rect:Rectangle = new Rectangle(0, 0, d.width, d.height);
			
			if(filterOffset){
				rect.x -= filterOffset.x;
				rect.y -= filterOffset.y;
				rect.width += filterOffset.x * 2;
				rect.height += filterOffset.y * 2;
			}
			
			var bpd2:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			bpd2.applyFilter(bpd, rect, new Point(), filter);
			
			bpd.dispose();
			
			return bpd2;
		}
		
		/**
		 * 绘制图像倒影 
		 */
		public static function drawInverted(d:DisplayObject,height:Number,alpha:Number = 0.3):Bitmap{
			var bp:Bitmap = new Bitmap(new BitmapData(d.width,height,true,0));
			var matrix:Matrix = new Matrix();
			matrix.ty = -height;
			bp.bitmapData.draw(d,matrix);
			bp.scaleY = -1;
			bp.y = d.height + height/1.7;
			bp.alpha = alpha;
			return bp;
		}
		
		/**
		 * 根据帧标签翻译MC 
		 * @param label 帧标签
		 */
		public static function translateMC(mc:MovieClip , label:String):void{
			if(label == null) return;
			for each(var o:Object in mc.currentLabels){
				if(o.name == label){
					mc.gotoAndStop(label);
					return;
				}
			}
			for(var i:int ; i < mc.numChildren ; i++){
				var d:DisplayObject = mc.getChildAt(i);
				if(d is MovieClip)translateMC(d as MovieClip , label);
			}
		}
		
		/**
		 * 去除位图中的颜色 
		 * @param bp 位图
		 * @param colors 颜色值
		 * @param merge 容差
		 * 
		 */
//		public static function deleteBitmapColor(bp:BitmapData , colors:Array , merge:int = 32):BitmapData{
//			var returnbp:BitmapData = new BitmapData(bp.width ,  bp.height , true , 0);
//			for(var x:int=0 ; x < bp.width ; x++){
//				for(var y:int=0 ; y < bp.height ; y++){
//					var c:uint = bp.getPixel(x,y);
//					var copy:Boolean = true;
//					for each(var pc:int in colors){
//						var rc:int = pc - c;
//						if(copy) copy = Math.abs(rc) > merge;
//					}
//					if(copy) returnbp.copyPixels(bp , new Rectangle(x,y) , new Point());
//				}
//			}
//			returnbp.copyPixels(
//			returnbp.threshold(bp,new Rectangle(0,0,bp.width,bp.height),new Point(),'==',0,colors[0]);
//			return returnbp;
//		}
		
		
		public static function transparent(source:*,arg1:* = null,arg2:* = null):BitmapData{
			var threshold:uint;
			var s:BitmapData = source is Bitmap ? source.bitmapData : source;
			if(arg1 == null){
				threshold = s.getPixel(0,0);
			}else {
				if(arg2 == null){
					threshold = arg1;
				}else{
					threshold = s.getPixel(arg1,arg2);
				}
			}
			var rect:Rectangle = new Rectangle(0,0,s.width,s.height);
			var origin:Point = new Point(0,0);
			var result:BitmapData = new BitmapData(s.width,s.height,true);
			result.copyPixels(s,rect,origin);
			result.threshold(s,rect,origin,"==",threshold,0,0xF0F0F0,true);
			return result;
		}
		
		/**
		 * 获取显示对象在目标对象的坐标 
		 * @param d 要移动的显示对象
		 * @param to 目标显示对象
		 * @return 
		 * 
		 */
		public static function getToChildPoint(d:DisplayObject,to:DisplayObjectContainer):Point{		
			var pt:Point = new Point(d.x,d.y);
			var p:DisplayObjectContainer = d.parent;
			while(p != null){
				pt.x += p.x;
				pt.y += p.y;
				if(p == to) return pt;
				p = p.parent;
			}
			trace(to , 'is not',d,"'s parent!");
			return pt;
		}
		
		/**
		 * 将一个显示对象移动到另一个显示对象里面 
		 * @param d 移动的显示对象
		 * @param to 目标显示对象
		 * @param fixParentPoint 自动调整移动的显示对象的坐标(仅在目标对象是移动对象的父级时有效)
		 * 
		 */
		public static function moveDisplay(d:DisplayObject,to:DisplayObjectContainer,fixParentPoint:Boolean = true):void{
			if(fixParentPoint){
				var p:Point = getToChildPoint(d,to);
				d.x = p.x;
				d.y = p.y;
			}
			to.addChild(d);
		}
		
		/**
		 * 在数字前面加0,zeroBeforNumber(1 , 3) return "001"
		 * @param n 数字
		 * @param bit 位数
		 */
		public static function addZeroBeforNumber(n:Number , bit:int = 2):String{
			var nstr:String = n.toString();
			var ii:int = nstr.indexOf('.',0);
			var after0:String = ii == -1 ? '' : nstr.substr(ii);
			var before0:String = ii == -1 ? nstr : nstr.substr(0,ii);
			var zeros:String = '';
			for(var i:int ; i < bit - before0.length ; i++) zeros += '0';
			return zeros + before0 + after0;
		}
		
		/**
		 * 获取URL的后缀名 
		 * @param v
		 * @return 
		 * 
		 */
		public static function getPostfix(v:String):String{
			var k:int = v.indexOf('?');
			var i:int;
			var pf:String;
			if(k == -1){
				i = v.lastIndexOf('.');
				pf = v.substr(i+1);
			}else{
				var s:String = v.substr(k - 5 , 5);
				i = s.indexOf('.');
				pf = s.substr(i+1);
			}
			return pf.toLowerCase();
		}
		
		public static function removeAllChildren(d:DisplayObjectContainer,itemCallFunction:Function = null):void{
			while(d.numChildren){
				var dd:DisplayObject = d.removeChildAt(0);
				if(itemCallFunction != null) itemCallFunction(dd);
			}
		}
		
		public static function removeChildByName(d:DisplayObjectContainer , name:String):void{
			var o:DisplayObject = d.getChildByName(name);
			if(o) d.removeChild(o);
		}
		
		public static function number2CN(n:int):String{
			var w:int,q:int,b:int,s:int;
			var r:String = '';
			if(n >= 10000){
				w = int(n / 10000);
				n -= 10000;
				r += num2cnbase(w) + '万';
			}
			if(n >= 1000){
				q = int(n / 1000);
				n -= 1000;
				r += num2cnbase(q) + '千';
			}else if(w > 0){
				r += '零';
			}
			if(n >= 100){
				b = int(n / 100);
				n -= b * 100;
				r += num2cnbase(b) + '百';
			}
			if(n >= 10){
				s = int(n / 10);
				n -= s * 10;
				if(b > 0){
					if(s > 0) r += num2cnbase(s) + '十';
				}
				if(b == 0){
					if(s == 1) r += '十';
					if(s > 1) r += num2cnbase(s) + '十';
				}
			}
			if(n>0 && s == 0 && b > 0){
				r += '零';
			}
			r += num2cnbase(n , r == '');
			return r;
		}
		private static function num2cnbase(n:int,showZero:Boolean = true):String{
			if(!showZero && n == 0) return '';
			var vv:Array = ['零','一','二','三','四','五','六','七','八','九'];
			return vv[n];
		}
		
		public static function appendTextAutoLine(txtfield:TextField , text:String):Boolean{
			var ll:int = txtfield.maxScrollV;
			var tmp:String = txtfield.text;
			txtfield.appendText(text);
			if(txtfield.maxScrollV > ll){
				txtfield.text = tmp + "\n" + text;
				return true;
			}
			return false;
		}
		
		public static function appendTextBottom(textfield:TextField , text:String , totalLines:int , html:Boolean = false):void{
			if(textfield.numLines <= 1){
				for(var i:int ; i < totalLines ; i++){
					if(html){
						textfield.htmlText += "<br/>";
					}else{
						textfield.appendText("\n");
					}
				}
			}
			if(html){
				textfield.htmlText += text;
			}else{
				textfield.appendText("\n" + text);
			}
			var m:int = textfield.getLineOffset(1);
			if(m != -1) textfield.replaceText(0,m,'');
		}
		
		public static function math_is_between(num:Number,num1:Number,num2:Number):Boolean{
			return (num >= num1 && num <= num2) || (num >= num2 && num <= num1);
		}
		
		public static function num_wake(n:Number , k:Number):Number{
			if(n > 0){
				n -= k;
				if(n < 0) n = 0;
			}
			if(n < 0){
				n += k;
				if(n > 0) n = 0;
			}
			return n;
		}
		
		public static function num_strong(n:Number , k:Number):Number{
			if(n < 0){
				n -= k;
			}else{
				n += k;
			}
			return n;
		}
		
		public static function num_fixRange(n:Number , range:Point):Number{
			if(n < range.x) n = range.x;
			if(n > range.y) n = range.y;
			return n;
		}
		
		public static function point_fixRange(p:Point , range:Rectangle):void{
			if(p.x < range.x) p.x = range.x;
			if(p.x > range.width) p.x = range.width;
			if(p.y < range.y) p.y = range.y;
			if(p.y > range.height) p.y = range.height;
		}
		
		/**
		 * 保留小数点后几位 
		 */
		public static function num_decimal(num:Number , deciaml:int = 1):Number{
			var i:int = int(num);
			var s:String = num.toString();
			var x:int = s.indexOf('.');
			if(x == -1) return i;
			
			var ds:String = s.substr(x , deciaml + 1);
			var d:Number = Number(ds);
			
			return i+d;
		}
		
		/**
		 * 将小数转化为百分比形式 
		 * @param v 小数
		 * @param decimal 小数位数，-1时不限制，0时为整数
		 */
		public static function num_toPersent(v:Number , decimal:int = -1):String{
			var vv:Number = v * 1000 / 10;
			if(decimal == -1){
				
			}else if(decimal == 0){
				vv = int(vv);
			}else{
				vv = num_decimal(vv,decimal);
			}
			return vv.toString() + '%';
		}
		
		/**
		 * 根据object给对象赋值 
		 * @param setter
		 * @param obj
		 */
		public static function setValueByObject(setter:* , obj:Object):void{
			if(!obj) return;
			for(var i:String in obj){
				var tmp:* = undefined;
				try{
					tmp = setter[i];
				}catch(e:Error){}
				
				var vv:Object = obj[i];
				
				if(tmp === undefined){
					try{
						setter[i] = vv;
					}catch(e:Error){
						trace('KyoUtils.setValueByObject :',e);
					}
					continue;
				}
				
				if(setter[i] is Boolean){
					if(vv is Boolean){
						setter[i] = vv;
					}else if(vv is Number){
						setter[i] = vv == 1;
					}else if(vv is String){
						setter[i] = vv == 'true' || vv == '1';
					}
				}else if(setter[i] is Number){
					setter[i] = Number(vv);
				}else{
					setter[i] = vv;
				}
				
			}
		}
		
		/**
		 * 克隆属性 
		 * @param to 克隆出来的对象
		 * @param from 原始对象
		 * @param keys 属性K值
		 */
		public static function cloneValue(to:* , from:*, keys:Array = null):*{
			if(keys){
				for each(var i:String in keys){
					to[i] = from[i];
				}
			}else{
				for(var j:String in from){
					to[j] = from[j];
				}
			}
			
			return to;
		}
		
		public static function cloneObject(from:Object):Object{
			var o:Object = {};
			for(var j:String in from){
				o[j] = from[j];
			}
			return o;
		}
		
		public static function setText(txt:TextField , text:Object = '' , mouseEnabled:Boolean = false , nulltxt:String = 'null' , autoSize:Boolean = false):void{
			var t:String = String(text);
			if(t == null) t = nulltxt;
			txt.mouseEnabled = mouseEnabled;
			txt.text = t;
			
			if(autoSize) textFieldAutoSize(txt);
		}
		
		public static function textFieldAutoSize(txt:TextField):void{
			var tf:TextFormat = txt.getTextFormat();
			if(txt.multiline == true){
				while(txt.textHeight > txt.height){
					tf.size = int(tf.size) - 1;
					txt.setTextFormat(tf);
				}
			}else{
				while(txt.textWidth > txt.width){
					tf.size = int(tf.size) - 1;
					txt.setTextFormat(tf);
				}
			}
			
		}
		
		/**
		 * 排序多个TextField 
		 * @param txts TextField数组
		 * @param startPos 开始位置
		 * @param direct 排序方向；0=横向,1=竖向
		 * @param autoSize 默认：TextFieldAutoSize.LEFT
		 * @param offset TextField宽高调整
		 */
		public static function alignTexts(txts:Array ,startPos:Number=NaN,direct:int = 0, autoSize:String = null , offset:Point = null):void{
			autoSize ||= TextFieldAutoSize.LEFT;
			
			var len:Number = startPos;
			
			if(isNaN(len)){
				var f:TextField = txts[0] as TextField;
				len = direct == 0 ? f.x : f.y;
			}
			
			for each(var i:TextField in txts){
				i.autoSize = autoSize;
				
				if(offset){
					i.width += offset.x;
					i.height += offset.y;
				}
				
				switch(direct){
					case 0:
						i.x = len;
						len += i.width;
						break;
					case 1:
						i.y = len;
						len += i.height;
						break;
				}
			}
		}
		
		public static function matchPoint(A:Point , B:Point):Boolean{
			if(!A || !B) return false;
			return A.x == B.x && A.y == B.y;
		}
		
		public static function matchRectangel(A:Rectangle , B:Rectangle):Boolean{
			if(!A || !B) return false;
			return A.x == B.x && A.y == B.y && A.width == B.width && A.height == B.height;
		}
		
		public static function rect_is_hit(rectA:Rectangle , rectB:Rectangle):Rectangle{
			function checkRect(rect:Rectangle):void{
				if(rect.width < 0){
					rect.width *= -1;
					rect.x -= rect.width;
				}
				if(rect.height < 0){
					rect.height *= -1;
					rect.y -= rect.height;
				}
			}
			
			checkRect(rectA);
			checkRect(rectB);
			
			var r:Rectangle = rectA.intersection(rectB);
			if(!r.isEmpty()) return r;
			return null;
		}
		
		/**
		 * 在MC的第N帧中加入方法 
		 * @param mc
		 * @param script
		 * @param frame -1时，加入到最后一帧
		 */
		public static function addFrameScript(mc:MovieClip , script:Function , frame:int = -1):void{
			var f:uint;
			if(frame == -1){
				f = mc.totalFrames - 1;
			}
			mc.addFrameScript(f , script);
		}
		
		/**
		 * 获取字符串的字节数 
		 * @param str 字符串
		 * @param encode 编码方式
		 */
		public static function string_length(str:String , encode:String = 'gb2312'):int{
			var bt:ByteArray = new ByteArray();
			bt.writeMultiByte(str,encode);
			return bt.length;
		}
		
		/**
		 * 去除后缀名 
		 */
		public static function str_removePrefix(v:String):String{
			var x:int = v.indexOf('.');
			if(x == -1) return v;
			return v.substr(0,x);
		}
		
		/**
		 * 字符串字符替换 
		 */
		public static function str_replaceALL(v:String,p:*,repl:*):String{
			return v.split(p).join(repl);
		}
		
		public static function str_matchALL(v:String , p:*):Array{
			var ra:Array = [];
			for(var i:int ; i < 10000 ; i++){
				var va:Array = v.match(p);
				if(!va || va.length < 1) break;
				var vs:String = va[1];
				v = v.replace(vs,'');
				ra.push(vs);
			}
			return ra.reverse();
		}
		
		/**
		 * 获取后缀名 
		 */
		public static function getPrefix(v:String):String{
			var x:int = v.indexOf('.');
			var pf:String = v.substr(x+1);
			return pf.toLocaleLowerCase();
		}
		
		/**
		 * 将MC的颜色支除（黑白化） 
		 * @param mc
		 * @param returnOrg 是否还原颜色
		 */
		public static function grayMC(mc:DisplayObject , returnOrg:Boolean = false):void{
			if(!mc) return;
			
			if(returnOrg){
				var fs:Array = mc.filters.concat();
				mc.filters = null;
				for each(var i:* in fs) if(i is ColorMatrixFilter)array_removeItem(fs,i);
				mc.filters = fs;
				return;
			}
			
			var mtx:Array = new Array();
			mtx = mtx.concat([0.3086, 0.6094, 0.082, 0, 0]); // red
			mtx = mtx.concat([0.3086, 0.6094, 0.082, 0, 0]); // green
			mtx = mtx.concat([0.3086, 0.6094, 0.082, 0, 0]); // blue
			mtx = mtx.concat([0, 0, 0, 1, 0]); // alpha
			var gray:ColorMatrixFilter = new ColorMatrixFilter(mtx);
			mc.filters = [gray];
		}
		
		public static function getObjLength(obj:Object):int{
			if(!obj) return 0;
			var l:int = 0;
			for each(var i:* in obj){
				if(i) l++;
			}
			return l;
		}
		
		public static function clone(v:Object):*{
			var myBA:ByteArray = new ByteArray();
			myBA.writeObject(v);
			myBA.position = 0;
			return myBA.readObject();
		}
		
		/**
		 * 读取字符串格式的变量。
		 * 格式为： 
		 *     变量名=值
		 *     变量名=值
		 *     //注释
		 *     变量名=值
		 */
		public static function readTextVariables(v:String):Object{
			var o:Object = {};
			
			v = StringUtil.replace(v,'\r','');
			var ps:Array = v.split('\n');
			var states:Array = [];
			var behind:String;
			for each(var i:String in ps){
				if(i.substr(0,2) == '//') continue;
				
				var p2:Array = i.split('=');
				var k:String = p2[0];
				var vv:Object = p2[1];
				o[k] = vv;
			}
			return o;
		}
		
		/**
		 * 获取对象类名 
		 */
		public static function getClass(o:Object):Class{
			var classname:String = getQualifiedClassName(o);
			return getDefinitionByName(classname) as Class;
		}
		
		/**
		 * 自定义右键菜单 
		 * @param main 原件MC
		 * @param menu 菜单名称数组
		 * @param select 选择菜单后调用的函数，返回菜单名称。
		 */
		public static function customMenu(main:Sprite , menu:Array , select:Function = null):void{
			var cm:ContextMenu = new ContextMenu();
			for each(var i:String in menu){
				var menuItem:ContextMenuItem = new ContextMenuItem(i);
				if(select != null) menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,function(e:ContextMenuEvent):void{
					select((e.currentTarget as ContextMenuItem).caption);
				});
				cm.customItems.push(menuItem);
			}
			if(main.stage) main.stage.showDefaultContextMenu = false;
			main.contextMenu = cm;
		}
		
		/**
		 * 将实体类对象转换为object，包含public的所有属性 
		 */
		public static function itemToObject(item:*):Object{
			var xml:XML = describeType(item);
			var o:Object = {};
			
			for each(var j:XML in xml.variable){
				var k:String = j.@name;
				o[k] = item[k];
			}
			
			return o;
		}
		
		/**
		 * 获取对象所有的PUBLIC属性 
		 * @return 属性名称数组
		 */
		public static function getItemVaribles(item:*):Array{
			var xml:XML = describeType(item);
			var a:Array = [];
			
			for each(var j:XML in xml.variable){
				var k:String = j.@name;
				a.push(k);
			}
			
			return a;
		}
		
		/**
		 * 克隆类定义的对象，所有public var的属性将进行克隆 (仅支持简单类型的属性)
		 * @param from
		 */
		public static function cloneSimpleClassObject(from:*):*{
			var o:Object = itemToObject(from);
			var cls:Class = getDefinitionByName(getQualifiedClassName(from)) as Class;
			var newItem:* = new cls();
			setValueByObject(newItem,o);
			return newItem;
		}
		
		public static function setMcVolume(mc:Sprite, volume:Number):void{
			if(!mc) return;
			var st:SoundTransform = mc.soundTransform;
			if(st){
				st.volume = volume;
				mc.soundTransform = st;
			}
		}
		
		public static function cloneColorTransform(ct:ColorTransform){
			var newCt:ColorTransform = new ColorTransform();
			
			newCt.alphaMultiplier = ct.alphaMultiplier;
			newCt.alphaOffset = ct.alphaOffset;
			
			newCt.blueMultiplier = ct.blueMultiplier;
			newCt.blueOffset = ct.blueOffset;
			
			newCt.greenMultiplier = ct.greenMultiplier;
			newCt.greenOffset = ct.greenOffset;
			
			newCt.redMultiplier = ct.redMultiplier;
			newCt.redOffset = ct.redOffset;
			
//			newCt.color = ct.color;
			
			return newCt;
			
		}
		
	}
}