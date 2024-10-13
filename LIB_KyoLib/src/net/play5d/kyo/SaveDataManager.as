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

package net.play5d.kyo {
import flash.net.SharedObject;

public class SaveDataManager {
    public function SaveDataManager(soname:String, localpath:String = null, secure:Boolean = false,
                                    autosave:Boolean                                       = false
    ) {
        _so = SharedObject.getLocal(soname, localpath, secure);
        _autosave = autosave;
    }
    private var _so:SharedObject;
    private var _autosave:Boolean;

    public function get hasData():Boolean {
        return _so.data._has_data_ == true;
    }

    public function get data():Object {
        return _so.data;
    }

    public function set data(data:Object):void {
        clear();
        addDataByObject(data);
        autosave();
    }

    public function getDataByKey(key:String):* {
        return _so.data[key];
    }

    public function updateData(key:String, value:Object):void {
        _so.data[key] = value;
        autosave();
    }

    public function addDataByObject(o:Object):void {
        for (var i:String in o) {
            _so.data[i] = o[i];
        }
        autosave();
    }

    public function clear():void {
        _so.clear();
    }

    public function save():void {
        if (!hasData) {
            updateData('_has_data_', true);
        }
        updateData('date_time', new Date());
        _so.flush();
    }

    public function autosave():void {
        if (_autosave) {
            save();
        }
    }

}
}
