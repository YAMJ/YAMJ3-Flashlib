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

import mx.utils.Delegate;

class dent.api.Socket {
	private var socket:XMLSocket=null;
	private var server:String=null;
	private var port:Number=null;
	private var mhandler:Function=null;
	private var sessionid:String=null;
	private var lastmessage:String=null;
	private var reconnecting:Boolean=false;

	private var fn:Object = null;

	public function Socket(server, port, mhandler, sessionid) {
		trace("new socket client to "+server+":"+port);

		if(server == undefined || server == null) {
			trace(".. no server to use");
			return;
		}

		if(port == undefined || port == null) {
			trace(".. no port to use");
			return;
		}

		if(mhandler == undefined || mhandler == null) {
			trace(".. no handler to use");
			return;
		}

		this.fn = {conn:Delegate.create(this, this.conn),
				   dropped:Delegate.create(this, this.dropped),
				   recv:Delegate.create(this, this.recv),
				   open:Delegate.create(this, this.open)
				  };

		this.sessionid=sessionid;
		this.server=server;
		this.mhandler=mhandler;
		this.port=port;

		this.opensocket();
	}

	private function opensocket() {
		this.socket = new XMLSocket();

		this.socket.onClose = this.fn.dropped;
		this.socket.onConnect = this.fn.conn;
		this.socket.onXML = this.fn.recv;

		this.open();
	}

	private function open() {
		trace("OPENING SOCKET TO "+this.server+":"+this.port);
		this.socket.connect(this.server, this.port);
	}

	private function dropped() {
		trace("SOCKET DROPPED BY "+this.server+":"+this.port);
		this.mhandler('down');
		this.socket.send('bye\n');
		this.socket.close();
	}

	public function reconnect() {
		this.reconnecting=true;
		_global["setTimeout"](this.fn.open, 3000);
	}

	private function conn(success) {
		if (success) {
			trace("socket connected to "+this.server+":"+this.port);
			this.mhandler('up');
			this.reconnecting=false;
		} else {
			if(this.reconnecting) {
				_global["setTimeout"](this.fn.open, 1400);
			} else {
				this.mhandler('fail');
			}
		}
	}

	private function disconnect() {
		trace("SOCKET DISCONNECTED TO "+this.server+":"+this.port);
		this.socket.send('bye\n');
		this.socket.close();
	}

	private function recv(line) {
		var sl:String=line.toString();
		if(sl=='bye') {
			trace(this.server+":"+this.port+" SIGNALED CONNECTION CLOSE");
			this.disconnect();
			this.mhandler('shutdown');
		} else {
			this.mhandler(line);
		}
	}
}
