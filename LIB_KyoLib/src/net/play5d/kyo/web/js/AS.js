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

+function()
{
	var arrRef = [window];
	var numRef = 0;

	var isIE = !window.addEventListener;
	var fla;



	function RefPut(val)
	{
		arrRef[++numRef] = val;
		return numRef;
	}


	function AS_Dispatch(id)
	{
		var args = [id];

		for(var i=1, n=arguments.length; i<n; i++)
		{
			args[i] = toAS(arguments[i]);
		}

		return fla.Notify.apply(fla, args);
	}


	function AS_Proxy(id)
	{
		return function()
		{
			return AS_Dispatch(id, this, arguments);
		}
	}


	function toAS(val)
	{
		switch(typeof val)
		{
		case "object":
			return "_OBJ" + RefPut(val);

		case "function":
			return "_FUN" + RefPut(val);
		}

		return val;
	}


	function toJS(val)
	{
		if(typeof val == "string")
		{
			switch(val.substr(0, 4))
			{
			case "_OBJ":
				return arrRef[+val.substr(4)];
			case "_FUN":
				if(!fla)
					fla = document.getElementById("fla");

				return AS_Proxy(+val.substr(4));
			}
		}

		return val;
	}


	js_in = function(id, name)
	{
		return name in arrRef[id];
	};


	js_get = function(id, name)
	{
		var val = arrRef[id][name];

		return toAS(val);
	};


	js_set = function(id, name, val)
	{
		arrRef[id][name] = toJS(val);
	};


	js_method = function(id, name)
	{
		var i = 0, n = arguments.length-2, $ = [];

		for(; i<n; i++)
			$[i] = toJS(arguments[i+2]);


		var obj = arrRef[id];

		if(isIE && !(obj instanceof Object))
		{
			// window.alert, prompt...
			// XMLHTTP.open, send...
			//   is object, not function
			switch(n)
			{
			case 0: return toAS(obj[name]());
			case 1: return toAS(obj[name]($[0]));
			case 2: return toAS(obj[name]($[0], $[1]));
			case 3: return toAS(obj[name]($[0], $[1], $[2]));
			case 4: return toAS(obj[name]($[0], $[1], $[2], $[3]));
			case 5: return toAS(obj[name]($[0], $[1], $[2], $[3], $[4]));
			default: return;
			}
		}

		var ret = obj[name].apply(obj, $);
		return toAS(ret);
	};


	js_call = function(id)
	{
		var i = 0, n = arguments.length-1, args = [];

		for(; i<n; i++)
			args[i] = toJS(arguments[i+1]);

		var ret = arrRef[id].apply(null, args);
		return toAS(ret);
	};


	js_new = function(id)
	{
		var i = 0, n = arguments.length-1, $ = [];

		for(; i<n; i++)
			$[i] = toJS(arguments[i+1]);

		switch(n)
		{
			case 0: return toAS(new arrRef[id]());
			case 1: return toAS(new arrRef[id]($[0]));
			case 2: return toAS(new arrRef[id]($[0], $[1]));
			case 3: return toAS(new arrRef[id]($[0], $[1], $[2]));
			case 4: return toAS(new arrRef[id]($[0], $[1], $[2], $[3]));
			case 5: return toAS(new arrRef[id]($[0], $[1], $[2], $[3], $[4]));
			case 6: return toAS(new arrRef[id]($[0], $[1], $[2], $[3], $[4], $[5]));
			case 7: return toAS(new arrRef[id]($[0], $[1], $[2], $[3], $[4], $[5], $[6]));
			case 8: return toAS(new arrRef[id]($[0], $[1], $[2], $[3], $[4], $[5], $[6], $[7]));
		}
	};
}()
