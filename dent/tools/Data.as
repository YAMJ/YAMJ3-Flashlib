// This file is part of YAMJ3-Flashlib.

// YAMJ3-Flashlib is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// YAMJ3-Flashlib is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with YAMJ3-Flashlib.  If not, see <http://www.gnu.org/licenses/>.

class dent.tools.Data {

// ************** XML

    // our base load xml class
	public static function loadXML(url:String, onLoad:Function, pass1, pass2):Void {
		if(url==undefined || url==null) onLoad(false, null, 10000, pass1, pass2);
		if(onLoad==undefined || onLoad==null) onLoad(false, null, 10001, pass1, pass2);

		var xml:XML = new XML();
		xml.ignoreWhite = true;

		xml.onLoad = function(success:Boolean):Void {
			if (success && xml.status==0) {
				onLoad(true, xml, null, pass1, pass2);
			} else {
				onLoad(false, xml, xml.status, pass1, pass2);
			}

			delete xml.idMap;
			xml = null;
		};
		xml.load(url);
	}

	// send only
	public static function sendXML(url:String) {
		Data.loadXML(url,function(){});
	}

	// load xml, make and array and return results
	public static function fastXMLArray(url:String,onLoad:Function,pass1) {
		//trace("fastxmlarray for "+url);
		Data.loadXML(url,Data.fastXMLArray_loaded,onLoad,pass1);
	}

	// after the xml for array is loaded
	public static function fastXMLArray_loaded(success,xml,errorcode, pass1,pass2) {
		if(success) {
			//trace(".. good");
			pass1(true,Data.arrayXML(xml.firstChild),errorcode,pass2);
		} else {
			//trace(".. bad");
			pass1(false,null,errorcode,pass2);
		}
	}

	// make an array out of key pair xml style, 1 deep
	public static function arrayXML(xml:XML) {
		var saveData:Object=new Object;

		// loop through the xml
		var myXML = xml.childNodes;

		for (var i=0; i<myXML.length; i++) {
			var dataName=myXML[i].nodeName.toString();
			var dataValue=myXML[i].firstChild.nodeValue.toString();
			//trace(":: "+dataName+" value "+dataValue);
			saveData[dataName]=dataValue;
		}
		if(saveData.length<1) return(null);

		return(saveData);
	}
}
