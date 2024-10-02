package net.play5d.kyo.loader
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class BMPLoader extends EventDispatcher
	{
		public static const EVENT_PARSE_ERROR:String = 'parseError';
		
		public function BMPLoader() {
		}
		
		public var content:Bitmap;
		
		private var _loader:URLLoader;
		private var _binaryArray:ByteArray;
		private var _crtPos:int=0;
		private var _url:String=null;
		private var isBm:Boolean;
		private var bfSize:Number;
		private var bfoffBits:Number;
		private var biSize:int;
		private var biWidth:int;
		private var biHeight:int;
		private var biPlanes:int;
		private var biBitCount:int;
		private var biCompression:int;
		private var biSizeImage:Number;
		private var biXpelsPerMeter:Number;
		private var biYPelsPerMeter:Number;
		private var biClrUsed:int;
		private var biClrImportant:int;
		private var arrayRGBQuad:Array;
		private var int1:int,int2:int,int3:int,int4:int;
		
		public function load(uq:URLRequest):void{
			_loader = new URLLoader();
			_loader.dataFormat=URLLoaderDataFormat.BINARY;
			_loader.addEventListener(IOErrorEvent.IO_ERROR,onError);
			_loader.addEventListener(Event.COMPLETE,onBmpLoadComplete);
			_loader.load(uq);
		}
		
		/**
		 * 读取字节 1个字节
		 */
		public function readbyte():int {
			_crtPos++;
			return _binaryArray.readByte();
		}
		
		/**
		 * 读取字节(非负) 2个字节
		 */
		public function readunsignedbyte():int {
			_crtPos++;
			return _binaryArray.readUnsignedByte();
		}
		
		private var short1:int;
		private var short2:int;
		
		/**
		 * 读16位
		 */
		public function readshort():int {
			_crtPos+=2;
			short1=_binaryArray.readUnsignedByte();
			short2=_binaryArray.readUnsignedByte();
			return short2<<8|short1;
		}
		/**
		 * 读32位 (非负)
		 */
		public function readuint():int {
			_crtPos+=4;
			int1=_binaryArray.readUnsignedByte();
			int2=_binaryArray.readUnsignedByte();
			int3=_binaryArray.readUnsignedByte();
			int4=_binaryArray.readUnsignedByte();
			return int4<<24|int3<<16|int2<<8|int1;
		}
		
		/**
		 * 读32位
		 */
		public function readint():int {
			_crtPos+=4;
			int1=_binaryArray.readByte();
			int2=_binaryArray.readByte();
			int3=_binaryArray.readByte();
			int4=_binaryArray.readByte();
			return int4<<24|int3<<16|int2<<8|int1;
		}
		
		private function onError(e:IOErrorEvent):void{
			dispatchEvent(e);
		}
		private function onBmpLoadComplete(e:Event):void {
			_loader.removeEventListener(Event.COMPLETE,onBmpLoadComplete);
			_binaryArray = _loader.data as ByteArray;
			var bmd:BitmapData = parseBmpData();
			_loader = null;
			if (bmd) {
				content = new Bitmap(bmd,"auto",true);
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function parseBmpData():BitmapData {
			//设置当前的解析字节数为0
			_crtPos=0;
			//位图文件的类型
			var temp1:int=readbyte();
			var temp2:int=readbyte();
			var bmd:BitmapData;
			if (temp1!=66||temp2!=77) {
				isBm=false;
				trace("这不是一张BMP格式的图片");
				dispatchEvent(new Event(EVENT_PARSE_ERROR));
				return null;
			}
			isBm=true;
			bfSize=readint();
			readshort();
			readshort();
			bfoffBits=readint();
			biSize=readint();
			biWidth=readuint();
			biHeight=readuint();
			biPlanes=readshort();
			biBitCount=readshort();
			biCompression=readint();
			biSizeImage=readint();
			biXpelsPerMeter=readint();
			biYPelsPerMeter=readint();
			biClrUsed=readint();
			biClrImportant=readint();
			
			var i:int,j:int;
			var r:int,g:int,b:int;
			var numline:int=0;
			if (biBitCount==24) {
				bmd = new BitmapData(biWidth,biHeight);
				bmd.lock();
				numline=0;
				for (j=biHeight-1; j>=0; j--) {
					numline=0;
					for (i=0; i<biWidth; i++) {
						b=readunsignedbyte();
						g=readunsignedbyte();
						r=readunsignedbyte();
						bmd.setPixel(i,j,r<<16|g<<8|b);
						numline+=3;
					}
					while (numline%4!=0) {
						numline++;
						readbyte();
					}
				}
				bmd.unlock();
			} else if (biBitCount==1||biBitCount==4||biBitCount==8) {
				var numcolors:int=bfoffBits-_crtPos/4;
				arrayRGBQuad=[];
				for (i=0; i<numcolors; i++) {
					var rgbObj:Object=new Object  ;
					rgbObj.b=readunsignedbyte();
					rgbObj.g=readunsignedbyte();
					rgbObj.r=readunsignedbyte();
					readunsignedbyte();
					arrayRGBQuad.push(rgbObj);
				}
				var rgb8:Object;
				bmd=new BitmapData(biWidth,biHeight);
				bmd.lock();
				numline=0;
				var ix1:int,ix2:int,ix3:int,ix4:int,ix5:int,ix6:int,ix7:int,ix8:int,ix0:int;
				for (j=biHeight-1; j>=0; j--) {
					numline=0;
					for (i=0; i<biWidth; ) {
						numline+=1;
						if (biBitCount==8) {
							ix1=readunsignedbyte();
							rgb8=arrayRGBQuad[ix1];
							r=rgb8.r;
							g=rgb8.g;
							b=rgb8.b;
							bmd.setPixel(i,j,r<<16|g<<8|b);
							i++;
						} else if (biBitCount==4) {
							ix1=readunsignedbyte();
							ix2=ix1>>4;
							ix3=ix1&0x0f;
							rgb8=arrayRGBQuad[ix2];
							r=rgb8.r;
							g=rgb8.g;
							b=rgb8.b;
							bmd.setPixel(i,j,r<<16|g<<8|b);
							i++;
							rgb8=arrayRGBQuad[ix3];
							r=rgb8.r;
							g=rgb8.g;
							b=rgb8.b;
							bmd.setPixel(i,j,r<<16|g<<8|b);
							i++;
						} else if (biBitCount==1) {
							ix0=readunsignedbyte();
							ix1=ix0>>4&8;
							ix2=ix0>>4&4;
							ix3=ix0>>4&2;
							ix4=ix0>>4&1;
							ix5=ix0&0x0f&8;
							ix6=ix0&0x0f&4;
							ix7=ix0&0x0f&2;
							ix8=ix0&0x0f&1;
							
							rgb8=arrayRGBQuad[ix1];
							r=rgb8.r;
							g=rgb8.g;
							b=rgb8.b;
							bmd.setPixel(i,j,r<<16|g<<8|b);
							i++;
							
							rgb8=arrayRGBQuad[ix2];
							r=rgb8.r;
							g=rgb8.g;
							b=rgb8.b;
							bmd.setPixel(i,j,r<<16|g<<8|b);
							i++;
							
							rgb8=arrayRGBQuad[ix3];
							r=rgb8.r;
							g=rgb8.g;
							b=rgb8.b;
							bmd.setPixel(i,j,r<<16|g<<8|b);
							i++;
							
							rgb8=arrayRGBQuad[ix4];
							r=rgb8.r;
							g=rgb8.g;
							b=rgb8.b;
							bmd.setPixel(i,j,r<<16|g<<8|b);
							i++;
							
							rgb8=arrayRGBQuad[ix5];
							r=rgb8.r;
							g=rgb8.g;
							b=rgb8.b;
							bmd.setPixel(i,j,r<<16|g<<8|b);
							i++;
							
							rgb8=arrayRGBQuad[ix6];
							r=rgb8.r;
							g=rgb8.g;
							b=rgb8.b;
							bmd.setPixel(i,j,r<<16|g<<8|b);
							i++;
							
							rgb8=arrayRGBQuad[ix7];
							r=rgb8.r;
							g=rgb8.g;
							b=rgb8.b;
							bmd.setPixel(i,j,r<<16|g<<8|b);
							i++;
							
							rgb8=arrayRGBQuad[ix8];
							r=rgb8.r;
							g=rgb8.g;
							b=rgb8.b;
							bmd.setPixel(i,j,r<<16|g<<8|b);
							i++;
						}
					}
					while (numline%4!=0) {
						numline++;
						readbyte();
					}
				}
				bmd.unlock();
			}
			return bmd;
		}
		
	}
}