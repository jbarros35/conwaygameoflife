var app = angular.module('myApp', []);
app.controller('ballOutCtrl', function($scope, $http) {
   
$scope.command = function (id) {
   $scope.commandId = id;
};

$scope.connected = false;
$scope.nick = null;
if ($scope.nick == null) {
 $scope.connected = false;
 // open modal directly from unlock button
 setTimeout(function() {
   document.getElementById('connect').click()        
 }, 0);
} else {
  $scope.connected = true;
}

// open modal for nickname connection.

 angular.element(document.querySelector('#openModal')).click();

  $scope.events = [];
  $scope.data = [];
  var connection = null;
   // if user is running mozilla then use it's built-in WebSocket
  $scope.connect = function() {
    window.WebSocket = window.WebSocket || window.MozWebSocket;
    connection = new WebSocket('wss://localhost:443', 'echo-protocol', { query: "foo=bar" });  

    connection.onopen = function () {
      // connection is opened and ready to use
      $scope.connected = true;
    };
  
    connection.onerror = function (error) {
      $scope.connected = false;
      // an error occurred when sending/receiving data
      $scope.showMessage = true;
      $scope.messageType = "danger";
      $scope.ResponseDetails = "Error on connecting server";
      $scope.$digest();
    };
  
    
  connection.onclose = function(message) {
    $scope.connected = false;
    $scope.showMessage = true;
    $scope.messageType = "danger";
    $scope.ResponseDetails = "Server connection was lost, check your connection.";
    $scope.$digest();
  }
  
  connection.onmessage = function (message) {
    // try to decode json (I assume that each message
    // from server is json)
    try {
	  var json = JSON.parse(message.data);
	  // save client id on first connection
	  if (json.event == 'client_id') {
      // set id
      connection.send(JSON.stringify({
        id: json.id,
        action: 'setnick',
        data: [],
        value: $scope.nick
        }
      ));
      $scope.client_uuid = json.id;
      $scope.showMessage = true;
      $scope.messageType = "success";
      $scope.ResponseDetails = $scope.nick+" client id: "+json.id;
      $scope.$digest();
      return;
	  }
	  // append to begin new events comming
	  $scope.events.unshift({id: json.nick, data:json.data, date: json.date, event: json.event});
	  $scope.$digest();
	} catch (e) {
      console.log('This doesn\'t look like a valid JSON: ',
          message.data);
      return;
    }
    // handle incoming message
  };
}

  $scope.send = function(action) {
	 if (connection && connection.readyState === connection.OPEN) {
      // Tell the server this is client 1 (swap for client 2 of course)
      connection.send(JSON.stringify({
      id: $scope.client_uuid,
      action: action,
      data: $scope.data
      }));
      $scope.events.unshift({id: $scope.nick, data:$scope.data, date: Date(), event: action});
      $scope.data = [];
      $scope.connected = true;
	 } else {
      $scope.connected = false;
      $scope.showMessage = true;
      $scope.messageType = "danger";
      $scope.ResponseDetails = "Tried to send data to server but connection was lost, check your connection.";
      $scope.$digest();
   }
  };
  
  $scope.addData = function() {
	  $scope.data.unshift([Number($scope.data2), Number($scope.data1)]);
	  $scope.data1 = null;
	  $scope.data2 = null;
  }

});
