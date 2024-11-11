/*
 * Copyright (C) 2021-2024, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package net.play5d.kyo.loader {

import flash.errors.IOError;
import flash.utils.*;

public class SwfHeaderInfo {

    public function SwfHeaderInfo(BA:ByteArray) {

        setWHruleList();
        parseByteArray(BA);
    }

    protected var w_h_ruleList:Array;

    protected var _type:String;//标识

    /**

     * Public get methods

     */

    public function get type():String {

        return _type;

    }

    protected var _version:uint;//版本

    public function get version():uint {

        return _version;

    }

    protected var _size:uint;//文件大小

    public function get size():uint {

        return _size;

    }

    protected var _width:uint;//场景宽

    public function get width():uint {

        return _width;

    }

    protected var _height:uint;//场景高

    public function get height():uint {

        return _height;

    }

    protected var _fps:uint;//桢频

    public function get fps():uint {

        return _fps;

    }

    protected var _frames:uint;//场景上的桢数

    public function get frames():uint {

        return _frames;

    }

    /**

     * Public methods

     */

    public function toString():String {

        return '[type:' + _type + ',version:' + _version + ',size:' + _size + ',width:' + _width + ',height:' +
               _height + ',fps:' + _fps + ',frames:' + _frames + ']';

    }

    protected function parseByteArray(BA:ByteArray):void {

        var binary:ByteArray = new ByteArray;

        binary.endian = Endian.LITTLE_ENDIAN;

        BA.readBytes(binary, 0, 8);//取前8个字节,包括了是否是swf,版本号,文件大小

        _type = binary.readUTFBytes(3);//前3个字节是SWF文件头标志，FWS表示未压缩，CWS表示压缩的SWF文件

        _version = binary[3];//第4个字节为版本号

        _size = binary[7] << 24 | binary[6] << 16 | binary[5] << 8 | binary[4];//文件大小按照8765字节的顺序排列的16进制

        //trace(_size,":size");

        //trace(_version,":version");

        binary.position = 8;//移到第9个字节位置，从这里开始就是swf 的控制码区和宽高数据区,宽高最多占用9个字节

        var mainData:ByteArray = new ByteArray;

        BA.readBytes(mainData);

        if (_type == 'CWS') {//未压缩的swf标识是FWS，压缩过的swf标识是CWS

            mainData.uncompress();//从第9个字节起用解压缩

        }
        else if (_type != 'FWS') {

            //trace("..."+_type+"...")

            throw new IOError('出错:不是swf文件！');

        }//不是cws,也不是fws,表示不是swf文件，抛出错误！

        binary.writeBytes(mainData, 0, 13);//再写13个字节，这里包括了swf的桢速/桢数

        //当前第8个字节位为控制码

        var ctrlCode:String = binary[8].toString(16);

        //trace(ctrlCode,":ctrlCode");

        var w_h_plist:Array = getW_H_RulePosition(w_h_ruleList, ctrlCode);

        var len:int = w_h_plist[2];

        //trace("宽高占用"+len+"个字节");

        var s:String = '';//存储宽高数据的相关字节码

        for (var i:int = 0; i < len; i++) {

            var _temp:String = binary[i + 9].toString(16);

            if (_temp.length == 1) {

                _temp = '0' + _temp;

            }

            s += _temp;


        }

        //trace(s);

        _width = new Number('0x' + s.substr(w_h_plist[0][0], 4)) / w_h_plist[0][1];

        _height = new Number('0x' + s.substr(w_h_plist[1][0], 4)) / w_h_plist[1][1];//相应取值得到宽高

        trace(width, ':width');

        trace(height, ':height');

        var pos:int = 8 + len;

        _fps = binary[pos += 2];//宽高数据区完跳一字节位置就是fps值

        //trace(_fps,":fps");

        _frames = binary[pos + 2] << 8 | binary[pos + 1];//桢数占两个字节，由低位到高位组成,是不是说时间轴的最大桢数就为65535?

        //trace(_frames,":frames");

    }

    protected function setWHruleList():void {//存储宽高的数据

        w_h_ruleList = [];

        w_h_ruleList[0] = {ctrlCode: '50', position: [[0, 10], [5, 10], 5]};

        w_h_ruleList[1] = {ctrlCode: '58', position: [[1, 40], [6, 10], 6]};

        w_h_ruleList[2] = {ctrlCode: '60', position: [[1, 10], [7, 10], 6]};

        w_h_ruleList[3] = {ctrlCode: '68', position: [[2, 40], [8, 10], 7]};

        w_h_ruleList[4] = {ctrlCode: '70', position: [[2, 10], [9, 10], 7]};

        w_h_ruleList[5] = {ctrlCode: '78', position: [[3, 40], [10, 10], 8]};

        w_h_ruleList[6] = {ctrlCode: '80', position: [[3, 10], [11, 10], 8]};

        w_h_ruleList[7] = {ctrlCode: '88', position: [[2, 40], [12, 10], 9]};

    }

    protected function getW_H_RulePosition(list:Array, str:String):Array {

        for (var i:String in list) {

            if (list[i].ctrlCode == str) {

                break;

            }

        }

        return list[i].position;

    }

}

}
