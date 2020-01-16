const scon = require('/Users/gezhixin/workSpace/code/Scon/Scon/Node/index.js');

function onDeviceChanged(deviceList) {
	for( var i in deviceList ){
		console.log(JSON.stringify(deviceList[i]));
	}
}

function addBonjourCallBack(f) {
	scon.starBonjour(f);
	process.nextTick(function(){});
}

scon.addMsgListener(function(msg) {
	console.log(msg);
});

addBonjourCallBack(onDeviceChanged);