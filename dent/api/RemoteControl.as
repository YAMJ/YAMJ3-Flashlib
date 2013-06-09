import dent.Common;
import dent.Player;
import dent.Dialog;
import dent.tools.Util;

class dent.api.RemoteControl {
	public static var halt:Boolean=false;
	public static var busy:Boolean=false;
	public static var remotemap:Object=null;
	public static var remotemapname:Object=null;
	public static var core:Function=null;
	public static var moved:Date=null;
	public static var popup:Boolean=false;

	// handlers
	public static var masterkeyListener:Object=null;

	public static function init() {
		trace("initing remote");

		RemoteControl.stop_remote();

		RemoteControl.masterkeyListener=new Object();
		Key.addListener(RemoteControl.masterkeyListener);
		RemoteControl.masterkeyListener.onKeyDown=RemoteControl.masterKeyHit;
	}

	public static function start_remote() {
		trace("starting remote");

		if(RemoteControl.remotemapname==null) {
			trace("no remote mappings yet");

			RemoteControl.remotemap=new Object();
			RemoteControl.remotemapname=new Object();
			Common.playerapi.keyboard(RemoteControl.remotemap,RemoteControl.remotemapname);
			Common.playerapi.remote(RemoteControl.remotemap,RemoteControl.remotemapname);

			RemoteControl.remotemapname['UP']=Key.UP;
			RemoteControl.remotemapname['DOWN']=Key.DOWN;
			RemoteControl.remotemapname['LEFT']=Key.LEFT;
			RemoteControl.remotemapname['RIGHT']=Key.RIGHT;

			RemoteControl.busy=false;
		}
		RemoteControl.halt=false;
		RemoteControl.moved=new Date();
	}

	public static function stop_remote() {
		trace("stopping remote");
		RemoteControl.halt=true;
	}

	public static function passRemote(hit) {
		if(RemoteControl.remotemapname[hit] == undefined) {
			trace("key skipped, not mapped");
		} else {
			masterKeyHit(RemoteControl.remotemapname[hit]);
		}
	}

	public static function masterKeyHit(keyhit):Void {
		if(Dialog.server_connecting) {
			Dialog.server_remote(Key.getCode());
			return;
		}
		if(popup) {
			Dialog.dialog_remote(Key.getCode());
			return;
		}

		if(RemoteControl.busy == false && RemoteControl.halt==false) {
			RemoteControl.busy=true;

			// idle stamp
			RemoteControl.moved=new Date();

			if(keyhit==undefined) {
				keyhit=Key.getCode();
			}
			trace("keyhit "+keyhit);
			//trace("ascii "+ Key.getAscii());

			// swapping keys around/overlap revers adjust
			if(RemoteControl.remotemap[keyhit]!=undefined) {
				keyhit=RemoteControl.remotemapname[RemoteControl.remotemap[keyhit]];
				trace("keyhit changed to "+keyhit);
			}

			var keyname:String=RemoteControl.keyname(keyhit)
			trace("keyname "+keyname);

			switch(keyhit) {
				// TODO: add the master force exit client here
				// probably should be a button list from the device, maybe switch no best anymore

				default:
					if(Player.remote(keyhit,keyname,false) == true) break;   // player non-nav buttons
					if(RemoteControl.core!=null && RemoteControl.core(keyhit,keyname) == true) break;  // core
					if(Player.remote(keyhit,keyname,true) == true) break;    // player nav buttons
					trace("remote press unused");
			}

			RemoteControl.busy=false;
		}
	}

	public static function keyname(keyhit) {
		for(var key:String in RemoteControl.remotemapname) {
			if (RemoteControl.remotemapname[key]==keyhit) return key;
		}
		return 'unknown keyhit';
	}

	public static function add_core(func) {
		trace("remote: connected to core");

		RemoteControl.core=func;
	}
}
