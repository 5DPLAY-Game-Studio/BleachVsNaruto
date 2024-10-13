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

package net.play5d.kyo.display.ui {
public class KyoRepeater {
    public function KyoRepeater() {
    }
    public var dataProvider:Array;
    public var bindClass:Class;
    public var bindProperty:Object;

    public function getItems():Array {
        var a:Array = [];
        for (var i:int; i < dataProvider.length; i++) {
            a.push(newItem(dataProvider[i]));
        }
        return a;
    }

    private function newItem(data:Object):Object {
        var o:Object = new bindClass();
        if (bindProperty) {
            if (bindProperty is String) {
                o[bindProperty] = bindProperty in data ? data[bindProperty] : data;
            }
            if (bindProperty is Array) {
                for each(var i:String in bindProperty) {
                    o[i] = data[bindProperty[i]];
                }
            }
        }
        return o;
    }

}
}
