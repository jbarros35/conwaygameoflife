var http = require('http');
var https = require('https');
var fs = require('fs');
const WebSocket = require('ws');
var uuid = require('node-uuid');

var privateKey  = fs.readFileSync('./key.pem', 'utf8');
var certificate = fs.readFileSync('./cert.pem', 'utf8');

var credentials = {key: privateKey, cert: certificate};
var express = require('express');
var app = express();

var options = {
  key: privateKey,
  cert: certificate,
  passphrase: '123456'
};

var server = https.createServer(options, function (req, res) {
  res.writeHead(200);
  res.end("hello world\n");
});

const wss = new WebSocket.Server({ server });
// prototype client id and socket
var Client = function(id, ws) {
  this.id = id,
  this.ws = ws
};
// full list of clients connected
var clientSet = [];

function noop() {}
// a keep alive check
function heartbeat() {
  this.isAlive = true;
}

wss.on('connection', function connection(ws, req) {
  
  const ip = req.connection.remoteAddress;
  var client_uuid = uuid.v1();
  console.log('%s new client connected %s', Date.now(), client_uuid);

  ws.isAlive = true;
  clientSet.push(new Client(client_uuid, ws));

  ws.send(
    JSON.stringify({ id: client_uuid })
  );

  wss.broadcast(JSON.stringify({id: client_uuid, event:'new client connected'}));

  ws.on('message', function incoming(message) {
    try {
      heartbeat();
      var msg = JSON.parse(message);
      wss.broadcast(JSON.stringify({id: msg.id, event:'action', 
      action: msg.action, data: msg.data}));
    } catch(e) {
      console.error('message cannot be parsed '+message)
    }
  });

});

// Broadcast to all except the client who generate the event.
wss.broadcast = function broadcast(data) {
  try {
    var message = JSON.parse(data);
    clientSet.forEach(function(client){
      if (client.id != message.id &&
        client.ws.readyState === WebSocket.OPEN) {
          client.ws.send(data);
      }
    });
  } catch(e){
    console.error(e);
  }
};

const interval = setInterval(function ping() {
  clientSet = clientSet.filter(function(client) {
    if (client.ws.isAlive === false && client.ws.readyState !== WebSocket.OPEN) {
      console.log("client id %s terminated", client.id);
      client.ws.terminate();
      return false;
    } else {
      client.ws.isAlive = false;
      client.ws.ping(noop);
      return true;
    }
  })
  console.log(clientSet);
}, 30000);


server.listen(443);