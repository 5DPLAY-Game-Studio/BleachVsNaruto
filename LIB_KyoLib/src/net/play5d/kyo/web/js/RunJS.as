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

package net.play5d.kyo.web.js {
import flash.display.*;

public class RunJS extends Sprite {
    function RunJS() {
        JSLine('DOM Demo:');
        JSDemo1();

        JSLine('Event Dem\o:');
        JSDemo2();

        JSLine('Closure Demo:');
        JSDemo3();

        JSLine('AJAX Demo:');
        JSDemo4();
    }

    // import DOM Interface
    private var window:JSEnv = JSEnv.$;

    function JSLine(str) {
        var doc = window.document;
        var div = doc.createElement('div');

        div.innerHTML = '<p>' + str + '<hr/></p>';
        doc.body.appendChild(div);
    }


    function JSDemo1() {
        var doc = window.document;
        var div = doc.createElement('div');

        div.innerHTML = 'Hello! <i>This box is created by ActionScript!</i>';

        div.style.background = '#CCC';
        div.style.font       = 'bolder 18px \'Courier New\'';
        div.style.border     = '1px dashed #693';

        doc.body.appendChild(div);
    }


    function JSDemo2() {
        var doc = window.document;
        var btn = doc.createElement('button');

        btn.innerHTML = 'Click Me!';
        btn.onclick   = function () {
            var i = 0;
            window.setInterval(function () {
                btn.innerHTML = 'Run in ActionScript: i=' + i++;
            }, 10);
        };

        doc.body.appendChild(btn);
    }


    function JSDemo3() {
        var doc = window.document;

        for (var i = 0; i < 5; i++) {
            var btn = doc.createElement('button');
            doc.body.appendChild(btn);

            btn.innerHTML = 'Button' + i;
            btn.onclick   = (
                    function (i) {
                        return function () {
                            window.alert(i);
                        };
                    }
            )(i);
        }
    }

    function JSDemo4() {
        var doc = window.document;
        var btn = doc.createElement('button');

        doc.body.appendChild(btn);

        btn.innerHTML = 'Load Test.xml';

        btn.onclick = function () {
            var xhr = window.ActiveXObject ?
                      new window.ActiveXObject('Microsoft.XMLHTTP') :
                      new window.XMLHttpRequest;

            xhr.onreadystatechange = function () {
                if (xhr.readyState != 4) {
                    return;
                }

                window.alert(xhr.responseText);
            };

            xhr.open('GET', 'Test.xml', true);
            xhr.send();
        };
    }
}
}
