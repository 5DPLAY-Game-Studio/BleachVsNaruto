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

package net.play5d.game.bvn.win.utils {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import net.play5d.game.bvn.interfaces.ILogger;

public class Loger implements ILogger {
    private static var _file:File;
    private static var _fileStream:FileStream;

    public function Loger() {
    }

    public function log(v:String):void {

        trace(v);

        if (!_file) {
            _file = new File(File.applicationDirectory.nativePath + '/log.log');
        }
        _fileStream = new FileStream();
        _fileStream.open(_file, FileMode.APPEND);
        _fileStream.writeUTFBytes(v + '\r\n');
        _fileStream.close();
        _fileStream = null;
    }

}
}
