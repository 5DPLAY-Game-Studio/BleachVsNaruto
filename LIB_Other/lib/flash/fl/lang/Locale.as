// Copyright © 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.lang
{
import flash.system.Capabilities;
import flash.xml.*;
import flash.net.*;
import flash.events.*;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.utils.Dictionary;

/**
 * The fl.lang.Locale class allows you to control how multilanguage text is displayed in a SWF file. 
 * The Flash Strings panel allows you to use string IDs instead of string literals in dynamic text fields. This allows you to create a SWF file that displays text loaded from a language-specific XML file. The XML file must use the XML Localization Interchange File Format (XLIFF). There are three ways to display the language-specific strings contained in the XLIFF files:
 * <ul>
 *   <li><code>"automatically at runtime"</code>&#x2014;Flash Player replaces string IDs with strings from the XML file matching the default system language code returned by flash.system.capabilities.language.</li>
 *   <li><code>"manually using stage language"</code>&#x2014;String IDs are replaced by strings at compile time and cannot be changed by Flash Player.</li>
 *   <li><code>"via ActionScript at runtime"</code>&#x2014;String ID replacement is controlled using ActionScript at runtime. This option gives you control over both the timing and language of string ID replacement.</li>
 * </ul>
 * <p>You can use the properties and methods of this class when you want to replace the string IDs "via ActionScript at runtime."</p>
 * <p>All of the properties and methods available are static, which means that they are accessed through the fl.lang.Locale class itself rather than through an instance of the class.</p>
 *
 * <p><b>Note:</b> The Locale class is installed in the Flash Authoring classpath and is automatically compiled into your SWF files. Using the Locale class increases the SWF file size slightly since the class is compiled into the SWF.</p>


 * @helpid 
 * @category Class
 * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @see flash.system.Capabilities#language
 */
public class Locale extends flash.events.EventDispatcher 
{
	private static var flaName:String;
	private static var defaultLang:String;
	private static var xmlLang:String = flash.system.Capabilities.language;
	private static var xmlMap:Object = new Object();
	private static var xmlDoc:XMLDocument;
	private static var stringMap:Object = new Object();
	private static var delayedInstanceDict:Dictionary = new Dictionary(true);
	private static var delayedInstanceParentDict:Dictionary = new Dictionary(true);
	private static var currentXMLMapIndex:Number = -1;
	private static var callback:Function;

	// new in Flash 8
	private static var autoReplacement:Boolean = true;			// should we assign text automatically after loading xml?
	private static var currentLang:String;						// the current language of stringMap
	private static var stringMapList:Object = new Object();		// the list of stringMap objects, used for caching

	private static var _xmlLoaded:Boolean = false;
	
	//******************************************
	//* Accessors
	//******************************************
	
	
    /** 
     * Determines whether strings are replaced automatically after loading the XML file. If set to <code>true</code>, the text 
     replacement method is equivalent to the Strings panel setting <code>"automatically at runtime"</code>. This means that Flash Player 
     will determine the default language of the host environment and automatically display the text in that language. If set to <code>
     false</code>, the text replacement method is equivalent to the Strings panel setting <code>"via ActionScript at runtime"</code>. 
     This means that you are responsible for loading the appropriate XML file to display the text.
     *
     * <p>The default value of this property reflects the setting that you select for Replace strings in the Strings panel dialog box: 
     <code>true</code> for <code>"automatically at runtime"</code> (the default setting) and <code>false</code> for "via ActionScript at 
     runtime". </p>
     *
     * @example The following example uses the <code>Locale.autoReplace</code> property to populate the dynamically created <code>
     greeting_txt</code> text field on the Stage with the contents of the <code>IDS_GREETING</code> string in the English XML file. In 
     the Strings panel, click the Settings button to open the Settings dialog box. You can add two active languages using the Settings 
     dialog box: English (en) and French (fr), set the replacement strings radio option to <code>"via ActionScript at runtime"</code>, 
     and click OK. Finally, enter a string ID of <b>IDS_GREETING</b> in the Strings panel, and add text for each active language.
     * <listing>
     * var greeting_txt:TextField = new TextField();
     * greeting_txt.x = 40;
     * greeting_txt.y = 40;
     * greeting_txt.width = 200;
     * greeting_txt.height = 20;
     * greeting_txt.autoSize = TextFieldAutoSize.LEFT;
     * Locale.autoReplace = true;
     * Locale.addDelayedInstance(greeting_txt, "IDS_GREETING");
     * Locale.loadLanguageXML("en");
     * </listing>
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @helpid 
     * @category Property
     * 
     * 
     */
	public static function get autoReplace():Boolean {
		return autoReplacement;
	}

	
	public static function set autoReplace(auto:Boolean):void {
		autoReplacement = auto;
	}

    /**
     * An array containing language codes for the languages that have been specified or loaded into the FLA file. The language codes are not sorted alphabetically.
     * 
     * @example The following example loads a language XML file based on the current value of a ComboBox component. You drag a ComboBox component onto the Stage and give it an instance name of <code>lang_cb</code>. Using the Text tool, you create a dynamic text field and give it an instance name of <code>greeting_txt</code>. In the Strings panel, you add at least two active languages, set the replace strings radio option to <code>"via ActionScript at runtime"</code>, and click OK. Next, you add a string ID of <b>IDS_GREETING</b> and enter text for each active language. Finally, you add the following ActionScript code to Frame 1 of the main Timeline:
     * <listing>
     * Locale.setLoadCallback(localeListener);
     * lang_cb.dataProvider = Locale.languageCodeArray.sort();
     * lang_cb.addEventListener("change", langListener);
     * 
     * function langListener(eventObj:Object):void {
     *  Locale.loadLanguageXML(eventObj.target.value);
     * }
     * function localeListener(success:Boolean):void {
     *  if (success) {
     *      greeting_txt.text = Locale.loadString("IDS_GREETING");
     *  } else {
     *      greeting_txt.text = "unable to load language XML file.";
     *  }
     * }
     * </listing>
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @helpid 
     * @category Property[read-only]
     *
     */
	public static function get languageCodeArray():Array {
		var langCodeArray:Array = new Array;
		for(var i:String in xmlMap) {
			if(i) {
				langCodeArray.push(i);
			}
		}

		return langCodeArray;
	}

    /** 
     * An array containing all the string IDs in the FLA file. The string IDs are not sorted alphabetically.
     * 
     * @example The following example traces the <code>Locale.stringIDArray</code> property for the currently loaded language XML file. 
     Click the Settings button in the Strings panel to open the Settings dialog box. Next, you add two active languages: English (en) and
     French (fr), set the replace strings radio control to <code>"via ActionScript at runtime"</code>, and click OK. In the Strings 
     panel, you add a string ID of <b>IDS_GREETING</b>, and then add text for each active language.
     * <listing>
     * Locale.setLoadCallback(localeCallback);
     * Locale.loadLanguageXML("fr");
     * function localeCallback(success:Boolean) {
     *  trace(success);
     *  trace(Locale.stringIDArray); // IDS_GREETING
     *  trace(Locale.loadStringEx("IDS_GREETING", "fr")); // bonjour
     * }
     * </listing>
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @helpid 
     * @category Property[read-only]
     */
	public static function get stringIDArray():Array {
		var strIDArray:Array = new Array;
		for(var i:String in stringMap) {
			if(i != "") {
				strIDArray.push(i);
			}
		}

		return strIDArray;
	}

	//*****************************************
	//* public methods
	//******************************************/

     /**
     * @private No need to document this, users won't need it. This is old code that isn't used by Flash Player 8, 
     * but is used when SWFs are published for Flash Player 7. 
     */
	public static function setFlaName(name:String):void {
		flaName = name;
	}

    /** 
     * The default language code as set in the Strings panel dialog box or by calling the <code>setDefaultLang()</code> method.
     * 
     * @return Returns the default language code.
     * 
     * @example The following example creates a variable called <code>defLang</code>, which is used to hold the initial default language 
     for the Flash document. You click the Settings button in the Strings panel to launch the Settings dialog box. Then you add two active 
     languages: English (en) and French (fr), set the replace strings radio control to <code>"via ActionScript at runtime"</code>, and 
     click OK. In the Strings panel, you add a string ID of <b>IDS_GREETING</b>, and then add text for each active language.
     * <listing>
     * var defLang:String = "fr";
     * Locale.setDefaultLang(defLang);
     * Locale.setLoadCallback(localeCallback);
     * Locale.loadLanguageXML(Locale.getDefaultLang());
     * function localeCallback(success:Boolean) {
     *  if (success) {
     *      trace(Locale.stringIDArray); // IDS_GREETING
     *      trace(Locale.loadString("IDS_GREETING"));
     *  } else {
     *      trace("unable to load XML");
     *  }
     * }
     * </listing>
     * @see #setDefaultLang() Locale.setDefaultLang()
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @helpid 
     * @category Method
     */
    public static function getDefaultLang():String {
		return defaultLang;
	}

    /** 
     * Sets the default language code.
     * @param langCode A string representing a language code.
     * 
     * @example The following example creates a variable called <code>defLang</code>, which is used to hold the initial default language for the Flash document. You click the Settings button in the Strings panel to open the Settings dialog box. Then you add two active languages: English (en) and French (fr), set the replace strings radio control to <code>"via ActionScript at runtime"</code>, and click OK. In the Strings panel, you add a string ID of <b>IDS_GREETING</b>, and then add text for each active language.
     * <listing>
     * var defLang:String = "fr";
     * Locale.setDefaultLang(defLang);
     * Locale.setLoadCallback(localeCallback);
     * Locale.loadLanguageXML(Locale.getDefaultLang());
     * function localeCallback(success:Boolean) {
     *  if (success) {
     *      trace(Locale.stringIDArray); // IDS_GREETING
     *      trace(Locale.loadString("IDS_GREETING"));
     *  } else {
     *      trace("unable to load XML");
     *  }
     * }
     * </listing>
     * @see #getDefaultLang() Locale.getDefaultLang()
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @helpid 
     * @category Method
     */
    public static function setDefaultLang(langCode:String):void {
		defaultLang = langCode;
	}

    /** 
     * Adds the {languageCode and languagePath} pair into the internal array for later use.
     * This is primarily used by Flash Player when the string's replacement method is <code>"automatically at runtime"</code>
     * or <code>"via ActionScript at runtime"</code>. This method allows you to load XML language files from a custom location
     * instead of the default location set up by Flash Professional. By default, Flash Professional creates an XML file for each
     * language in your working directory, under a subdirectory named using your FLA file's name. 
     * @param langCode The language code.
     * @param path The XML path to add.
     * 
     * @example The following example tells Flash Player that the English ("en") translations are found in the file 
     * "locale/locale_en.xml" file and French ("fr") translations are in the "locale/locale_fr.xml" file relative to your working
     * directory (example and description provided by Chris Inch, from 
     * <a href="http://www.chrisinch.com" target="_blank">http://www.chrisinch.com</a>):
     * <listing>
     * Locale.addXMLPath("en", "locale/locale_en.xml");
	 * Locale.addXMLPath("fr", "locale/locale_fr.xml");
	 * Locale.setLoadCallback(Delegate.create(this, languageLoaded));
	 * Locale.loadLanguageXML("en");
	 *
	 * private function languageLoaded(success:Boolean):Void {
	 *    trace(Locale.loadString("IDS_HELLO");
	 *}
     * </listing>
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @helpid 
     * @category Method
     */ 
	public static function addXMLPath(langCode:String, path:String):void {
		if(xmlMap[langCode] == undefined) {
			xmlMap[langCode] = new Array();
		}
		
		xmlMap[langCode].push(path);
	}


    /** 
     * Adds the {instance, string ID} pair into the internal array for later use.
     * This is primarily used by Flash when the strings replacement method is <code>"automatically at runtime"</code>. 
     * @param instance Instance name of the text field to populate.
     * @param stringID Language string ID.
     * 
     * @example The following example uses the <code>autoReplace</code> property and <code>addDelayedInstance()</code> method to populate
     a text field on the Stage with the <code>IDS_GREETING</code> string from the English XML language file.
     * <listing>
     * greeting_txt.autoSize = TextFieldAutoSize.LEFT;
     * Locale.autoReplace = true;
     * Locale.addDelayedInstance(greeting_txt, "IDS_GREETING");
     * Locale.loadLanguageXML("en");
     * </listing>
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @helpid 
     * @category Method
     */
	public static function addDelayedInstance(instance:Object, stringID:String) {
		if (instance.hasOwnProperty("text")) {
			delayedInstanceDict[instance] = stringID;
		} else if (instance.hasOwnProperty("parent") && instance.parent is DisplayObjectContainer && instance.hasOwnProperty("instanceName")) {
			var parent:DisplayObjectContainer = DisplayObjectContainer(instance.parent);
			var realInstance:DisplayObject = (parent.hasOwnProperty(instance.instanceName)) ? (parent[instance.instanceName] as DisplayObject): null;
			if (realInstance == null) realInstance = parent.getChildByName(instance.instanceName);
			if (realInstance == null) {
				var parentDict:Dictionary = delayedInstanceParentDict[parent];
				if (parentDict == null) parentDict = delayedInstanceParentDict[parent] = new Dictionary(false);
				parentDict[instance.instanceName] = stringID;
				if (_xmlLoaded) parent.addEventListener(Event.ADDED, addedListener);
			} else if (_xmlLoaded) {
				if (realInstance.hasOwnProperty("text")) realInstance["text"] = loadString(stringID);
			} else {
				delayedInstanceDict[realInstance] = stringID;
			}
		}
	}

    /**
     * Returns <code>true</code> if the XML file is loaded; <code>false</code> otherwise. 
     * @return Returns <code>true</code> if the XML file is loaded; <code>false</code> otherwise.
     * 
     * @example The following example uses an interval to check every 10 milliseconds to see if the language file has successfully 
     loaded. Once the XML file has loaded, the <code>greeting_txt</code> text field instance on the Stage is populated with the 
     <code>IDS_GREETING</code> string from the language XML file.
     * <listing>
     * Locale.setLoadCallback(localeCallback);
     * Locale.loadLanguageXML("en");
     * // create interval to check if language XML file is loaded
     * var locale_int:Number = setInterval(checkLocaleStatus, 10);
     * function checkLocaleStatus():void {
     *  if (Locale.checkXMLStatus()) {
     *      clearInterval(locale_int);
     *      trace("clearing interval &#64; " + getTimer() + " ms");
     *  }
     * }
     * // callback function for Locale.setLoadCallback()
     * function localeCallback(success:Boolean):void {
     *  greeting_txt.text = Locale.loadString("IDS_GREETING");
     * }
     * </listing>
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @helpid 
     * @category Method
     */ 
    public static function checkXMLStatus():Boolean {
		return _xmlLoaded;
	}

    /**
     * Sets the callback function that is called after the XML file is loaded.
     * @param loadCallback The function to call when the XML language file loads.
     * 
     * @example The following example uses an interval to check every 10 milliseconds to see if the language file has successfully 
     loaded. Once the XML file has loaded, the <code>greeting_txt</code> text field instance on the Stage is populated with the 
     <code>IDS_GREETING</code> string from the XML language file.
     * <listing>
     * Locale.setLoadCallback(localeCallback);
     * Locale.loadLanguageXML("en");
     * // create interval to check if language XML file is loaded
     * var locale_int:Number = setInterval(checkLocaleStatus, 10);
     * function checkLocaleStatus():void {
     *  if (Locale.checkXMLStatus()) {
     *      clearInterval(locale_int);
     *      trace("clearing interval &#64; " + getTimer() + " ms");
     *  }
     * }
     * // callback function for Locale.setLoadCallback()
     * function localeCallback(success:Boolean):void {
     *  greeting_txt.text = Locale.loadString("IDS_GREETING");
     * }
     * </listing>
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @helpid 
     * @category Method
     */
    public static function setLoadCallback(loadCallback:Function) {
		callback = loadCallback;
	}

    /** 
     * Returns the string value associated with the given string ID in the current language.
     * @param id The identification (ID) number of the string to load.
     * @return The string value associated with the given string ID in the current language.
     * 
     * @example The following example uses an interval to check every 10 milliseconds to see if the language file has successfully 
     loaded. Once the XML file has loaded, the <code>greeting_txt</code> text field instance on the Stage is populated with the 
     <code>IDS_GREETING</code> string from the XML language file.
     * <listing>
     * Locale.setLoadCallback(localeCallback);
     * Locale.loadLanguageXML("en");
     * // create interval to check if language XML file is loaded
     * var locale_int:Number = setInterval(checkLocaleStatus, 10);
     * function checkLocaleStatus():void {
     *  if (Locale.checkXMLStatus()) {
     *      clearInterval(locale_int);
     *      trace("clearing interval &#64; " + getTimer() + " ms");
     *  }
     * }
     * // callback function for Locale.setLoadCallback()
     * function localeCallback(success:Boolean):void {
     *  greeting_txt.text = Locale.loadString("IDS_GREETING");
     * }
     * </listing>
     * @see #loadStringEx() Locale.loadStringEx()
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @helpid 
     * @category Method
     */
    public static function loadString(id:String):String {
		return stringMap[id];
	}

    /**
     * Returns the string value associated with the given string ID and language code.
     * To avoid unexpected XML file loading, <code>loadStringEx()</code> does not load the XML language file if the XML file is not 
     already loaded. You should decide on the right time to call the <code>loadLanguageXML()</code> method if you want to load a XML 
     language file.
     * @param stringID The identification (ID) number of the string to load.
     * @param languageCode The language code.
     * @return The string value associated with the given string ID in the language specified by the <code>languageCode</code> parameter.
     * 
     * @example The following example uses the <code>loadStringEx()</code> method to trace the value of the <code>IDS_GREETING</code> 
     string for the currently loaded French language XML file.
     * <listing>
     * Locale.setLoadCallback(localeCallback);
     * Locale.loadLanguageXML("fr");
     * function localeCallback(success:Boolean) {
     *  trace(success);
     *  trace(Locale.stringIDArray); // IDS_GREETING
     *  trace(Locale.loadStringEx("IDS_GREETING", "fr")); // bonjour
     * }
     * </listing>
     * @see #loadString() Locale.loadString()
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @helpid 
     * @category Method
     */
	public static function loadStringEx(stringID:String, languageCode:String):String {
		var tmpMap:Object = stringMapList[languageCode];
		if (tmpMap) {
			return tmpMap[stringID];
		} else {
			return "";
		}
	}

    /** 
     * Sets the new string value of a given string ID and language code.
     *
     * @param stringID The identification (ID) number of the string to set.
     * @param languageCode The language code.
     * @param stringValue A string value.
     *
     * @example The following example uses the <code>setString()</code> method to set the <code>IDS_WELCOME</code> string for both English
     (en) and French (fr).
     * <listing>
     * Locale.setString("IDS_WELCOME", "en", "hello");
     * Locale.setString("IDS_WELCOME", "fr", "bonjour");
     * trace(Locale.loadStringEx("IDS_WELCOME", "en")); // hello
     * </listing>
     *
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @helpid 
     * @category Method
     */
    public static function setString(stringID:String, languageCode:String, stringValue:String):void {
		var tmpMap:Object = stringMapList[languageCode];
		if (tmpMap) {
			tmpMap[stringID] = stringValue;
		} else {
			// the map doesn't exist, possibly haven't loaded the language xml file yet, but we store the string anyway
			tmpMap = new Object();
			tmpMap[stringID] = stringValue;
			stringMapList[languageCode] = tmpMap;
		}
	}

    /** 
     * Automatically determines the language to use and loads the XML language file.
     * This is primarily used by Flash when the strings replacement method is <code>"automatically at runtime"</code>.
     * 
     * @example This example shows how to use the <code>initialize()</code> method to automatically populate the <code>greeting_txt
     </code> text field on the Stage with the user's current OS language. Instead of using the <code>initialize()</code> method directly,
     use the string replacement method of <code>"automatically at runtime"</code>.
     * <listing>
     * trace(System.capabilities.language);
     * Locale.autoReplace = true;
     * Locale.addDelayedInstance(greeting_txt, "IDS_GREETING");
     * Locale.initialize();
     * </listing>
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @helpid 
     * @category Method
     */
	public static function initialize():void {
		var langCode:String = xmlLang;
		if(xmlMap[xmlLang] == undefined) {
			langCode = defaultLang;
		}

		currentXMLMapIndex = 0;
		loadXML(langCode);
		
		
	}

    /** 
     * Loads the specified XML language file.
     * 
     * @param xmlLanguageCode The language code for the XML language file that you want to load.
     * @param customXmlCompleteCallback Custom callback function to call when XML language file loads.
     * 
     * @example The following example uses the <code>loadLanguageXML()</code> method to load the English (en) XML language file. Once the
     language file loads, the <code>localeCallback()</code> method is called and populates the <code>greeting_txt</code> text field on 
     the Stage with the contents of the <code>IDS_GREETING</code> string in the XML file.
     * <listing>
     * Locale.setLoadCallback(localeCallback);
     * Locale.loadLanguageXML("en");
     * // create interval to check if language XML file is loaded
     * var locale_int:Number = setInterval(checkLocaleStatus, 10);
     * function checkLocaleStatus():void {
     *  if (Locale.checkXMLStatus()) {
     *      clearInterval(locale_int);
     *      trace("clearing interval &#64; " + getTimer() + " ms");
     *  }
     * }
     * // callback function for Locale.setLoadCallback()
     * function localeCallback(success:Boolean):void {
     *  greeting_txt.text = Locale.loadString("IDS_GREETING");
     * }
     * </listing>
     * @playerversion Flash 9
     * @playerversion AIR 1.0
     * @productversion Flash CS3
     * @langversion 3.0
     * @helpid 
     * @category Method
     */
    public static function loadLanguageXML(xmlLanguageCode:String, customXmlCompleteCallback:Function=null):void {
		// if xmlLang is not defined, set to SystemCapabilities.language
		var langCode:String = (xmlLanguageCode == "") ? flash.system.Capabilities.language : xmlLanguageCode;
		if(xmlMap[langCode] == undefined) {
			// if the specified language is not defined, set to default language
			langCode = defaultLang;
		}

		if (customXmlCompleteCallback != null) {
			callback = customXmlCompleteCallback;
		}

		if (stringMapList[xmlLanguageCode] == undefined) {
			loadXML(langCode);
		} else {
			// the xml is already loaded, retrieve it from the list
			stringMap = stringMapList[langCode]

			// call the callback here because onLoad is not called here
			if (callback != null)
				callback(true);
		}
		currentLang = langCode;
	}

	//******************************************
	//* private methods
	//******************************************/

	private static function loadXML(langCode:String) {
		var xmlURL:String = xmlMap[langCode][0];
		var myLoader:URLLoader = new URLLoader(new URLRequest(xmlURL));
		myLoader.addEventListener("complete", onXMLLoad);
	}
	 
	 
	 
	private static function onXMLLoad(eventObj:Event) {
		_xmlLoaded = true;
		var theLoader:URLLoader = eventObj.target as URLLoader;
		var loadedXMLText:String = theLoader.data;
		xmlDoc = new XMLDocument();
		xmlDoc.ignoreWhite = true;
		xmlDoc.parseXML(loadedXMLText);
		
		stringMap = new Object();

		parseStringsXML(xmlDoc);

		// store the string map in the list for caching
		if (stringMapList[currentLang] == undefined) {
			stringMapList[currentLang] = stringMap;
		}

		if (autoReplacement) {
			assignDelayedInstances();
		}
		
		if (callback != null)
			callback(true);
	}

	private static function parseStringsXML(doc:XMLDocument):void {
		if(doc.childNodes.length > 0 && doc.childNodes[0].nodeName == "xliff") {
			parseXLiff(doc.childNodes[0]);
		}
	}

	private static function parseXLiff(node:XMLNode):void {
		if(node.childNodes.length > 0 && node.childNodes[0].nodeName == "file") {
			parseFile(node.childNodes[0]);
		}
	}

	private static function parseFile(node:XMLNode):void {
		if(node.childNodes.length > 1 && node.childNodes[1].nodeName == "body") {
			parseBody(node.childNodes[1]);
		}
	}

	private static function parseBody(node:XMLNode):void {
		for(var i:Number = 0; i < node.childNodes.length; i++) {
			if(node.childNodes[i].nodeName == "trans-unit") {
				parseTransUnit(node.childNodes[i]);
			}
		}
	}

	private static function parseTransUnit(node:XMLNode):void {
		var id:String = node.attributes.resname;
		if(id.length > 0 && node.childNodes.length > 0 &&
				node.childNodes[0].nodeName == "source") {
			var value:String = parseSource(node.childNodes[0]);
			if(value.length > 0) {
				stringMap[id] = value;
			}
		}
	}

	// return the string value of the source node
	private static function parseSource(node:XMLNode):String {
		if(node.childNodes.length > 0) {
			return node.childNodes[0].nodeValue;
		}

		return "";
	}

	private static function assignDelayedInstances():void {
		var key:*;
		for (key in delayedInstanceDict) {
			key.text = loadString(delayedInstanceDict[key]);
		}

		var key2:*;
		for (key in delayedInstanceParentDict) {
			var parent:DisplayObjectContainer = DisplayObjectContainer(key);
			var parentDict:Dictionary = delayedInstanceParentDict[key];
			for (key2 in parentDict) {
				var instanceName:String = String(key2);
				var instance:DisplayObject = (parent.hasOwnProperty(instanceName)) ? (parent[instanceName] as DisplayObject): null;
				if (instance == null) instance = parent.getChildByName(instanceName);
				if (instance == null) {
					parent.addEventListener(Event.ADDED, addedListener);
				} else {
					var stringID:String = parentDict[key2];
					if (instance.hasOwnProperty("text")) instance["text"] = loadString(stringID);
					delete parentDict[key2];
				}
			}
			var dictEmpty:Boolean = true;
			for (key2 in parentDict) {
				dictEmpty = false;
				break;
			}
			if (dictEmpty) {
				parent.removeEventListener(Event.ADDED, addedListener);
				delete delayedInstanceParentDict[key];
			}
		}
	}

	private static function addedListener(e:Event):void {
		var parent:DisplayObjectContainer = e.currentTarget as DisplayObjectContainer;
		if (parent == null) return;
		var instance:DisplayObject = e.target as DisplayObject;
		if (instance == null || instance.parent != parent) return;
		var parentDict:Dictionary = delayedInstanceParentDict[parent];
		if (parentDict == null) return;
		var stringID:String = parentDict[instance.name];
		if (stringID == null) return;
		if (instance.hasOwnProperty("text")) instance["text"] = loadString(stringID);
		delete parentDict[instance.name];
		var dictEmpty:Boolean = true;
		for (var key:* in parentDict) {
			dictEmpty = false;
			break;
		}
		if (dictEmpty) {
			parent.removeEventListener(Event.ADDED, addedListener);
			delete delayedInstanceParentDict[key];
		}
	}

}
}