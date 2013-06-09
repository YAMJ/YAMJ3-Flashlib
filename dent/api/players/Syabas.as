import dent.Common;
import dent.Dialog;
import dent.tools.Data;
import dent.api.Playerapi;
import dent.api.Socket;
import dent.api.Server;
import mx.xpath.XPathAPI;
import mx.utils.Delegate;

class dent.api.players.Syabas extends Playerapi {
	private var fn:Object = null;
	private var socket:Socket=null;
	private var socketcallback:Function=null;

	// init
	public function Syabas() {
		this.fn = {after_detect:Delegate.create(this, this.after_detect),
				   fromsocket:Delegate.create(this, this.fromsocket)
				  };
	}

	// ****** CONNECTIONS
	public function realtime_start(callback) {
		trace("SYABAS: starting realtime connect");
		this.connect(callback);
	}

	private function connect(callback) {
		if(this.socket==null) {
			trace("connected to syabas cmd server");

			this.socketcallback=callback;
			this.socket=new Socket(Common.runtime.player, 8118, this.fn.fromsocket);
		}
	}

	// TODO: CLOSE?????

	private function fromsocket(command) {
		//TODO: update socket control to re-establish on drops/player needs/parsing.

		var sc=command.toString();
		switch(sc) {
			case 'down':      // connection suddenly dropped
			case 'up':         // connection established
			case 'connected':		   // connection with control established
			case 'shutdown':  // server signed shutdown
			case 'fail':      // connection failed to establish
			case 'reject':    // server rejected last message (bad sessionid, need to re-establish)
				trace("HW SOCKET: todo reminder, skipped command "+sc);
				return;
			default:
				// todo: process this, don't just log pass it.
				var d:String=XPathAPI.selectSingleNode(command.firstChild, "/theDavidBox");
				this.socketcallback(d);
		}
	}

    // ****** SETTINGS

	// name
	private function name() {
		return("syabas hardware");
	}

	private function id() {
		return("syabas");
	}

	private function remote(remotemap,remotemapname) {
		trace("syabas remote keys");

		// default mappings
		remotemapname['FILEMODE']=0x10000405;
		remotemapname['TITLE']=0x10000406;
		remotemapname['REPEAT']=0x10000407;
		remotemapname['ANGLE']=0x10000408;
		remotemapname['SLOW']=0x10000409;
		remotemapname['TIMESEEK']=0x1000040A;
		remotemapname['ZOOM']=0x1000040B;
		remotemapname['TVMODE']=0x1000040C;
		remotemapname['AUDIO']=0x01000017;
		remotemapname['SOURCE']=0x1000040E;
		remotemapname['EJECT']=0x1000040F;
		remotemapname['MUTE']=0x01000003;
		remotemapname['PLAY']=0x01000007;
		remotemapname['PAUSE']=0x01000008;
		remotemapname['STOP']=0x01000009;
		remotemapname['FWD']=0x0100000A;
		remotemapname['REW']=0x0100000B;
		remotemapname['NEXT']=0x0100000C;
		remotemapname['PREV']=0x0100000D;
		remotemapname['MENU']=0x01000012;
		remotemapname['INFO']=0x01000013;
		remotemapname['BACK']=0x01000016;
		remotemapname['AUDIO']=0x01000017;
		remotemapname['SUBTITLE']=0x01000018;
		remotemapname['RED']=0x0100001F;
		remotemapname['GREEN']=0x01000020;
		remotemapname['YELLOW']=0x01000021;
		remotemapname['BLUE']=0x01000022;
		remotemapname['SEARCH']=268436490;
		remotemapname['SETUP']=0x0100001C;
		remotemapname['EQUAL']=187;
		remotemapname['COMMA']=188;
		remotemapname['SEMICOLON']=186;
		remotemapname['NUM0']=48;
		remotemapname['NUM1']=49;
		remotemapname['NUM2']=50;
		remotemapname['NUM3']=51;
		remotemapname['NUM4']=52;
		remotemapname['NUM5']=53;
		remotemapname['NUM6']=54;
		remotemapname['NUM7']=55;
		remotemapname['NUM8']=56;
		remotemapname['NUM9']=57;
		remotemapname['ENTER']=Key.ENTER;
		remotemapname['SELECT']=Key.ENTER;
		remotemapname['PAGEUP']=Key.PGUP;
		remotemapname['PAGEDOWN']=Key.PGDN;

		remotemap[0x1000040D]="AUDIO";  // I forget the overlap and why I made them both audio
	}

	private function find_server(callback) {
		// TODO: check the 300 again for the arg passing commands, I forgot the syntax
		callback(false);
	}

	// detect my hardware
	private function detect(callback) {
		trace("checking for syabas hardware");

		if(Common.runtime.player==undefined) {
			Common.runtime.player="127.0.0.1";
		}

		Data.loadXML("http://"+Common.runtime.player+":8008/"+"system?arg0=system_info",this.fn.after_detect,callback);
	}

	private function after_detect(success, xml, errorcode, callback) {
		if(success) {
			trace("found "+xml);

			// name
			var temp:String=XPathAPI.selectSingleNode(xml.firstChild, "/theDavidBox/response/name").firstChild.nodeValue.toString();
			if(temp!=undefined && temp!= null) {
				Dialog.update_splash(temp);
			} else {
				Dialog.update_splash("Popcorn Hour 200 Series");
			}

			callback(true);
		} else {
			trace("not syabas hardware");
			callback(false);
		}
	}

// ************* playback
	private function youtube() {
		return true;
	}

	private function play_single(data) {
		// play a single file
		trace("syabas play");
		return true;
	}
}
