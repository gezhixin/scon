const test_object = require(`./build/Release/bonjour`);

test_object.publish({   
    'name': 'hello world!',
    'domain': 'local.',
    'type': "_scon._tcp",
    'port': 8989
});

function sleep (time) {
    return new Promise((resolve) => setTimeout(resolve, time));
}

var date = new Date();
var curDate = null;
do { curDate = new Date(); }
while(curDate-date < 3000);

test_object.stop();
console.log('stop');

while(1);