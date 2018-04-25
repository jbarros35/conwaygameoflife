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
var Client = function(id, nick, ws, date) {
  this.id = id,
  this.nick = nick,
  this.ws = ws,
  this.date = date,
  this.lastActivity = date
};

// full list of clients connected
var clientSet = [];

wss.on('connection', function connection(ws, req) {
  
  const ip = req.connection.remoteAddress;
  var client_uuid = uuid.v1();
  console.log('%s new client connected %s', new Date(), client_uuid);

  ws.isAlive = true;
  clientSet.push(new Client(client_uuid, null, ws, new Date()));
  // send client id
  ws.send(
    JSON.stringify({ id: client_uuid, event: 'client_id'})
  );

  ws.on('message', function incoming(message) {
    try {
      var msg = JSON.parse(message);
      // update client activity log
      var client = getClientId(msg.id)[0];
      if (client) {
        client['lastActivity'] = new Date();
        client['isAlive'] = true;
      }
      // first message from client is the nick-name set
      if (msg.action === 'setnick') {
        client['nick'] = msg.value;
         // broadcast on connect new client
         wss.broadcast(JSON.stringify(
          {id: client_uuid, 
            nick: msg.value,
            data: [],
            date: new Date(),
            event:'client_connected'}));
        return;
      }
      // the rest of messages...
      wss.broadcast(JSON.stringify(
        {id: msg.id, 
          nick: client.nick,
          event: msg.action, 
          data: msg.data,
          date: new Date()
        }));
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

function getClientId(id) {
  return clientSet.filter(function(client){
    if (client.id === id) {
      return client;
    }
  });
};

function getTimeElapsed(date) {
  var today = new Date();
  var diffMs = (today - date); // milliseconds between now & Christmas
  var diffDays = Math.floor(diffMs / 86400000); // days
  var diffHrs = Math.floor((diffMs % 86400000) / 3600000); // hours
  var diffMins = Math.round(((diffMs % 86400000) % 3600000) / 60000); // minutes
  return {ms: diffMs, days: diffDays, hours: diffHrs, minutes: diffMins};
};

const interval = setInterval(function ping() {
  var disconnected = [];
  clientSet = clientSet.filter(function(client) {
    var lastActivity = getTimeElapsed(client.lastActivity);
    if (client.ws.isAlive === false 
      && client.ws.readyState !== WebSocket.OPEN
    || lastActivity.ms >= 5000 * 60) {
      console.log("client id %s terminated last activity: %s", client.id, lastActivity.ms);
      client.ws.terminate();
      disconnected.push(client);
      return false;
    } else {
      client.ws.isAlive = false;
      console.log("client id %s is online last activity: %s", client.id, lastActivity.ms);
      return true;
    }
  });

  // tell all clients that someone disconnected
  disconnected.forEach(function(client){
    wss.broadcast(JSON.stringify({id: client.id, date: Date(), nick: client.nick, event:'disconnected'}));
  });
  
}, 30000);

server.listen(443);