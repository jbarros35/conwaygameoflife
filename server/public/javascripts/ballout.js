var app = angular.module('myApp', []);
app.controller('ballOutCtrl', function($scope, $http) {
   console.log('ballout init');
   
$scope.command = function (id) {
   $scope.commandId = id;
};

  $scope.events = [];
     
   // if user is running mozilla then use it's built-in WebSocket
  window.WebSocket = window.WebSocket || window.MozWebSocket;

  var connection = new WebSocket('wss://localhost:443', 'echo-protocol');

  connection.onopen = function () {
    // connection is opened and ready to use
	console.log('client opened socket');
  };

  connection.onerror = function (error) {
    // an error occurred when sending/receiving data
    $scope.showMessage = true;
		$scope.messageType = "danger";
		$scope.ResponseDetails = "Error on connecting server";
		$scope.$digest();
  };

  connection.onmessage = function (message) {
    // try to decode json (I assume that each message
    // from server is json)
    try {
	  var json = JSON.parse(message.data);
	  // save client id on first connection
	  if (json.event == 'client_id') {
      $scope.client_uuid = json.id;
      $scope.showMessage = true;
      $scope.messageType = "success";
      $scope.ResponseDetails = "Your client id: "+json.id;
      $scope.$digest();
      return;
	  }
	  // append to begin new events comming
	  $scope.events.unshift({id: json.id, data:json.data, date: json.date, event: json.event});
	  $scope.$digest();
	} catch (e) {
      console.log('This doesn\'t look like a valid JSON: ',
          message.data);
      return;
    }
    // handle incoming message
  };
  
  $scope.send = function(action) {
  // Tell the server this is client 1 (swap for client 2 of course)
  connection.send(JSON.stringify({
   id: $scope.client_uuid,
   action: action,
   data: $scope.data
   }));
   $scope.data = null;
  };
  
});
