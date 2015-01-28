// node.js v0.10.25 or higher | ref: https://gist.github.com/ma2shita/c5daa68069837639c374
// $ cd EMITTER_ROOT
// $ sudo node example/ti_sensortag_simplekey.js
var SensorTag = require('sensortag');
var net = require('net');

console.log("Please PowerOn SensorTag");
SensorTag.discover(function(sensorTag) { console.log(">> STOP: Ctrl+C or SensorTag power off");
	sensorTag.connect(function() { console.log("found: discovery service ...");
		sensorTag.discoverServicesAndCharacteristics(function() { /* very slow */
			sensorTag.readDeviceName(function(deviceName) { console.log("connect: " + deviceName);
				sensorTag.notifySimpleKey(function() { console.log("start: notifySimpleKey");
					console.log("// left right (x = pushed, o = opened) //");
					sensorTag.on("simpleKeyChange", function(left, right) { /* run per pushed button */
						var btn_st = 0x00; /* ボタンが押された時のみ送信するようにするためのフィルタ変数 */
						var send_str = "";
						if (left)  {
							btn_st += 0x10;
							send_str += "    x";
						} else {
							send_str += "    o";
						}
						if (right) {
							btn_st += 0x01;
							send_str += "     x";
						} else {
							send_str += "     o";
						}
						if (0x00 != (btn_st & 0x11)) {
							console.log(send_str);
							var client = net.connect({path: './tmp/example_in_literal.sock'}, function() {
								client.write(send_str);
								client.end();
							});
						}
					});
				});
			});
		});
	});
	/* In case of SensorTag power off or out of range when fired `onDisconnect` */
	sensorTag.on("disconnect", function() { console.log("disconnect");
		process.exit(0);
	});
});

