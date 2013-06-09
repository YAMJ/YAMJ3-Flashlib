import dent.Common;
import dent.Dialog;
import dent.tools.Data;
import dent.api.Hardware;
import dent.api.RemoteControl;
import dent.api.Socket;
import dent.api.Server;
import mx.xpath.XPathAPI;

class dent.api.Control {
// **************** Connect
	public static function start_socket(cb) {
		// "realtime" hardware monitoring
		Common.playerapi.realtime_start(Control.fromHardware);

		cb(true);
	}

// **************** Communicate

	public static function fromHardware(command) {
		var d=command.toString();
		trace('HW SOCKET: '+d);

		switch(d) {
			default:
				trace("unknown hw socket command: "+d);
		}
	}

// **************** Control

// TODO: LOTS OF STUFF

}
