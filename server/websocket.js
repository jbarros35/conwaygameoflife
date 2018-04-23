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

wss.on('connection', function connection(ws, req) {
  
  const ip = req.connection.remoteAddress;
  var client_uuid = uuid.v1();

  ws.send(
    JSON.stringify({ id: client_uuid })
  );

  ws.on('message', function incoming(message) {
    try {
      var msg = JSON.parse(message);
      console.log('client id %s, action %s, data %s', msg.id, msg.action, msg.data);
    } catch(e) {
      console.error('message cannot be parsed '+message)
    }
  });

});

server.listen(443);