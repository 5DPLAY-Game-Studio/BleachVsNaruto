/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
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

package net.play5d.game.bvn.mob.utils {
import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;
import flash.utils.Timer;

import net.play5d.game.bvn.interfaces.ILogger;

/**
 * 移动文件日志：缓冲后追加到用户目录，并按大小轮转。
 *
 * <p>路径为应用存储目录下的 <code>logs/bvn.log</code>。
 * 缓冲满 32 行或 8KB、级别为 <code>ERROR</code>、或每隔 1 秒时落盘。
 * 单文件达到 512KB 时轮转，连当前文件共保留 3 个。
 * 写入失败只报告一次并停止写文件。应用退出时刷出剩余缓冲。</p>
 *
 * @example
 * <listing version="3.0">
 * GameLogger.setLogger(new Logger());
 * </listing>
 * @see net.play5d.game.bvn.interfaces.ILogger
 */
public class Logger implements ILogger {

    /** @private */
    private static const MAX_LINES:int      = 32;
    /** @private */
    private static const MAX_BUFFER:int     = 8 * 1024;
    /** @private */
    private static const MAX_FILE:int       = 512 * 1024;
    /** @private */
    private static const BACKUP_COUNT:int   = 2;
    /** @private */
    private static const FLUSH_INTERVAL:int = 1000;
    /** @private */
    private static const LOG_DIR:String     = 'logs';
    /** @private */
    private static const LOG_NAME:String    = 'bvn.log';
    /** @private */
    private static const ERROR_LEVEL:String = 'ERROR';

    /** @private */
    private var _file:File;
    /** @private */
    private var _timer:Timer;
    /** @private */
    private var _buffer:String           = '';
    /** @private */
    private var _lines:int               = 0;
    /** @private */
    private var _bytes:int               = 0;
    /** @private 写失败后不再打开文件 */
    private var _enabled:Boolean         = true;
    /** @private */
    private var _failureReported:Boolean = false;

    /**
     * 创建文件日志，定时刷盘，并在应用退出时写出剩余缓冲。
     *
     * @example
     * <listing version="3.0">
     * var logger:Logger = new Logger();
     * </listing>
     */
    public function Logger() {
        NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
        _timer = new Timer(FLUSH_INTERVAL);
        _timer.addEventListener(TimerEvent.TIMER, onTimer);
        _timer.start();
    }

    /**
     * 输出一行并按策略写入文件。
     *
     * <p>始终 <code>trace</code>。文件写入进入缓冲。</p>
     *
     * @param msg 已格式化的一行，不含换行。
     * @example
     * <listing version="3.0">
     * logger.log('12:00:00.000 INFO [sys] init...');
     * </listing>
     * @see net.play5d.game.bvn.interfaces.ILogger#log()
     */
    public function log(msg:String):void {
        trace(msg);
        if (!_enabled) {
            return;
        }

        var chunk:String = msg + File.lineEnding;
        _buffer += chunk;
        _lines++;
        _bytes += byteLength(chunk);
        if (_lines >= MAX_LINES || _bytes >= MAX_BUFFER || isErrorLine(msg)) {
            flush();
        }
    }

    /** @private */
    private function onTimer(event:TimerEvent):void {
        flush();
    }

    /** @private */
    private function onExiting(event:Event):void {
        flush();
    }

    /** @private */
    private function flush():void {
        if (!_enabled || !_buffer) {
            return;
        }

        var payload:String   = _buffer;
        var payloadBytes:int = _bytes;
        _buffer = '';
        _lines  = 0;
        _bytes  = 0;

        var stream:FileStream = new FileStream();
        var opened:Boolean    = false;
        try {
            ensureFile();
            if (_file.exists && _file.size > 0 && _file.size + payloadBytes >= MAX_FILE) {
                rotate();
            }
            stream.open(_file, FileMode.APPEND);
            opened = true;
            stream.writeUTFBytes(payload);
        }
        catch (error:Error) {
            disable(error);
        }
        finally {
            if (opened) {
                try {
                    stream.close();
                }
                catch (closeError:Error) {
                    // 关闭失败不掩盖写入错误
                }
            }
        }
    }

    /** @private */
    private function ensureFile():void {
        if (_file) {
            return;
        }

        var dir:File = File.applicationStorageDirectory.resolvePath(LOG_DIR);
        if (!dir.exists) {
            dir.createDirectory();
        }
        _file = dir.resolvePath(LOG_NAME);
    }

    /** @private */
    private function rotate():void {
        var dir:File    = _file.parent;
        var oldest:File = backupFile(dir, BACKUP_COUNT);
        if (oldest.exists) {
            oldest.deleteFile();
        }

        for (var i:int = BACKUP_COUNT; i >= 1; i--) {
            var source:File = i == 1 ? _file : backupFile(dir, i - 1);
            if (!source.exists) {
                continue;
            }
            source.moveTo(backupFile(dir, i), true);
        }

        _file = dir.resolvePath(LOG_NAME);
    }

    /** @private */
    private static function backupFile(dir:File, index:int):File {
        return dir.resolvePath('bvn.' + index + '.log');
    }

    /** @private */
    private static function isErrorLine(line:String):Boolean {
        // 门面行格式的第二段是级别名
        var first:int  = line.indexOf(' ');
        if (first < 0) {
            return false;
        }

        var second:int = line.indexOf(' ', first + 1);
        if (second < 0) {
            return false;
        }

        return line.substring(first + 1, second) == ERROR_LEVEL;
    }

    /** @private */
    private static function byteLength(text:String):int {
        var raw:ByteArray = new ByteArray();
        raw.writeUTFBytes(text);

        return raw.length;
    }

    /** @private */
    private function disable(error:Error):void {
        _enabled = false;
        _buffer  = '';
        _lines   = 0;
        _bytes   = 0;
        if (_timer) {
            _timer.stop();
        }
        if (_failureReported) {
            return;
        }

        _failureReported = true;
        trace('Logger file disabled: ' + error.message);
    }

}
}
