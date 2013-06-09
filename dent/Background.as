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

import dent.Common;
import dent.api.RemoteControl;
import dent.tools.Util;
import dent.tools.StringUtil;

class dent.Background {
	// control
	public static var bgInterval=null;
	public static var bgtasks:Array=null;

	// clock
	public static var lastclock:String=null;
	public static var lastdate:String=null;
	public static var lastdow:String=null;
	public static var lastshortdow:String=null;
	private static var timelayout:String="12";
	private static var datelayout:String="MM-DD-YYYY";

	// lookup
	private static var dowlookup:Array=['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
	private static var dowshortlookup:Array=['Sun','Mon','Tues','Wed','Thurs','Fri','Sat'];
	private static var monthlookup:Array=['','Janurary','Feburary','March','April','May','June','July','August','September','October','November','December'];
	private static var monthshortlookup:Array=['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

// ********* BG SETUP
	public static function init() {
		Background.reset();

		Background.bgtasks=new Array();

		// idle
		Background.add("idle", 60, 30, Background.idle);
		Background.add("idle", 3, 10, Background.clock);

		// start it ticking
		Background.start();

		// run the clock once for first draw
		Background.clock();
	}

	public static function reset() {
		Background.stop();

		delete Background.bgtasks;
		Background.bgtasks=null;

		trace("background reset");
	}

	public static function start() {
		Background.bgInterval = setInterval(Background.control,1000);
		trace("background started");
	}

	public static function stop() {
		clearInterval(Background.bgInterval);
		Background.bgInterval=null;
		trace("background stopped");
	}

// ********* BG CONTROL
	public static function control() {
		//trace("background control called");
		for(var tt in Background.bgtasks) {
			if(Background.bgtasks[tt].current<2) {
				Background.bgtasks[tt].call();
				if(Background.bgtasks[tt].reset==0) {
					Background.bgtasks[tt].current=9999;
					Background.bgtasks[tt].name="DELETED";
				} else {
					Background.bgtasks[tt].current=Background.bgtasks[tt].reset;
				}
			} else {
				if(Background.bgtasks[tt].name!="DELETED") Background.bgtasks[tt].current--;
			}
		}
	}

	public static function add(name:String, start:Number, interval:Number, call:Function) {
		trace("adding "+name);

		var found:Boolean=false;
		for(var tt in Background.bgtasks) {
			if(Background.bgtasks[tt].name==start) {
				trace("already added, updating settings");
				Background.bgtasks[tt].name=name;
				Background.bgtasks[tt].current=start;
				Background.bgtasks[tt].reset=interval;
				Background.bgtasks[tt].call=call;
				found=true;
				break;
			}
		}
		if(found==false) {
			trace(".. added");
			Background.bgtasks.push({name:name, current:start, reset:interval, call:call});
		}
	}

// ************************ IDLE
	public static function idle() {
		//trace("idle checking");

		if(RemoteControl.moved==null) {
			//trace('skipped, remote not ready');
			return;
		}

		var d:Date=new Date();
		var diff:Number=Math.floor((d-RemoteControl.moved)/60000);

		//trace("idle for "+diff+" minutes");
	}

	public static function clock() {
		//trace("clock");

		// make time
		var mydate = new Date();
		var minutes = mydate.getMinutes();
		var hours = mydate.getHours();
		delete mydate;

		if (minutes<10) {
			minutes = "0"+minutes;
		}

		// TODO: REAL SETTING
		if(Common.runtime.timelayout=="12") {	// 12 hour
			if (hours>12 ) {
				hours = hours-12;
				var ampm = "PM";
			} else if (hours == 12) {
				var ampm = "PM";
			} else {
				var ampm = "AM";
			}
			if (hours == 0) {
					  hours = 12;
			}
			var newclock:String=hours+":"+minutes+" "+ampm;
		} else {	// 24 hour
			if (hours<10) {
				hours = "0"+hours;
			}
			var newclock:String=hours+":"+minutes;
		}

		// date
		var month=mydate.getMonth();
		month++;
		if(month<10) month="0"+month;

		var day=mydate.getDate();
		if(day<10) day="0"+day;

		var year=mydate.getFullYear();

		switch(Common.runtime.datelayout) {
			case 'YYYY-MM-DD':
				var newdate=year+"-"+month+"-"+day;
				break;
			case 'DD-MMM-YYYY':
				var newdate=day+"-"+monthshortlookup[month]+"-"+year;
				break;
			default:  // MM-DD-YYYY
				var newdate=month+"-"+day+"-"+year;
		}


		// dow
		var dayN = mydate.getDay();
		var dow=dowlookup[dayN];
		var shortdow=dowshortlookup[dayN];

		// skip if nothing to do
		if(newclock == lastclock && newdate == lastdate && dow==lastdow) {
			//trace("update clock skipped, time the same");
			return;
		}

		lastclock=newclock;
		lastdate=newdate;
		lastdow=dow;
		lastshortdow=shortdow;

		// find the clocks
		update_clock('SCREEN0');
		update_clock('SCREEN1');
	}

	private static function update_clock(clip) {
		if(!Util.notfound(Common.stage[clip])) {
			walk_clip(Common.stage[clip]);
		}
	}

	private static function walk_clip(parent, name) {
		for(var p in parent) {
			if(typeof(parent[p]) == "movieclip") {
				walk_clip(parent[p], name);
			} else if(typeof(parent[p]) == "object") {
				if(StringUtil.beginsWith(parent[p]._name, "clock")) {
					var txtfmt=parent[p].getTextFormat();
					parent[p].text=lastclock;
					parent[p].setTextFormat(txtfmt);
				} else if(StringUtil.beginsWith(parent[p]._name, "date")) {
					var txtfmt=parent[p].getTextFormat();
					parent[p].text=lastdate;
					parent[p].setTextFormat(txtfmt);
				} else if(StringUtil.beginsWith(parent[p]._name, "dowshort")) {
					var txtfmt=parent[p].getTextFormat();
					parent[p].text=lastshortdow;
					parent[p].setTextFormat(txtfmt);
				} else if(StringUtil.beginsWith(parent[p]._name, "dow")) {
					var txtfmt=parent[p].getTextFormat();
					parent[p].text=lastdow;
					parent[p].setTextFormat(txtfmt);
				}
			}
		}
	}
}
