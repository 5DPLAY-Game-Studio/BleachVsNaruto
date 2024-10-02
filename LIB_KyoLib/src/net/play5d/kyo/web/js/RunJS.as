package net.play5d.kyo.web.js
{
	import flash.display.*;
	

	public class RunJS extends Sprite
	{
		// import DOM Interface
		private var window:JSEnv = JSEnv.$;
		
		
		function RunJS()
		{
			JSLine("DOM Demo:");
			JSDemo1();
			
			JSLine("Event Dem\o:");
			JSDemo2();
			
			JSLine("Closure Demo:");
			JSDemo3();
			
			JSLine("AJAX Demo:");
			JSDemo4();
		}
		
		
		function JSLine(str)
		{
			var doc = window.document;
			var div = doc.createElement("div");
			
			div.innerHTML = "<p>" + str + "<hr/></p>"
			doc.body.appendChild(div);
		}
		
		
		function JSDemo1()
		{
			var doc = window.document;
			var div = doc.createElement("div");
			
			div.innerHTML = "Hello! <i>This box is created by ActionScript!</i>";
			
			div.style.background = "#CCC";
			div.style.font = "bolder 18px 'Courier New'";
			div.style.border = "1px dashed #693";
			
			doc.body.appendChild(div);
		}
		
		
		function JSDemo2()
		{
			var doc = window.document;
			var btn = doc.createElement("button");
			
			btn.innerHTML = "Click Me!";
			btn.onclick = function()
			{
				var i = 0;
				window.setInterval(function()
				{
					btn.innerHTML = "Run in ActionScript: i=" + i++;
				}, 10)
			};
			
			doc.body.appendChild(btn);
		}
		
		
		function JSDemo3()
		{
			var doc = window.document;
			
			for(var i=0; i<5; i++)
			{
				var btn = doc.createElement("button");
				doc.body.appendChild(btn);
				
				btn.innerHTML = "Button" + i;
				btn.onclick = (function(i)
				{
					return function(){window.alert(i)};
				})(i);
			}
		}
		
		function JSDemo4()
		{
			var doc = window.document;
			var btn = doc.createElement("button");
			
			doc.body.appendChild(btn);
	
			btn.innerHTML = "Load Test.xml";

			btn.onclick = function()
			{
				var xhr = window.ActiveXObject?
					new window.ActiveXObject("Microsoft.XMLHTTP"):
					new window.XMLHttpRequest;
				
				xhr.onreadystatechange = function()
				{
					if(xhr.readyState != 4)
						return;
					
					window.alert(xhr.responseText);
				};

				xhr.open("GET", "Test.xml", true);
				xhr.send();
			};
		}
	}
}