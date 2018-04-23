var app = angular.module('myApp', []);
app.controller('ballOutCtrl', function($scope, $http) {
   console.log('ballout init');
   
   $scope.command = function (id) {
	   $scope.commandId = id;
   };
   
   $scope.submitCommand = function() {
	  var id = $scope.commandId;
		switch(id) {
		case "unlock":
			$scope.unlockAccount();
			break;
		case "create":
		    console.log("call create account");
			$scope.createAccount();
			break;
		case "submitBallout":
			console.log("call submit ballout");
			break;
		default:
			console.log("unknown command");
		}
   };
  
  $scope.createAccount = function() {
		var data = $.param({
			password: $scope.password
		});
		
		var config = {
			headers : {
				'Content-Type': 'application/x-www-form-urlencoded'
			}
		};
		
		$http.post('/createAccount', data, config)
			.success(function (data, status, headers, config) {
				if (data) {
					$scope.showMessage = true;
				    $scope.messageType = "success";
					$scope.ResponseDetails = "Account created successfully, your address is "+data.address+" you must save it to submit proposals.";
					$scope.address = null;
					$scope.password = null;
					$scope.commandId = null;
				}				
			})
			.error(function (data, status, header, config) {
				$scope.showMessage = true;
				$scope.messageType = "warning";
				$scope.ResponseDetails = "Error on creation your account passphrase is invalid.";
			});
   };
  
   $scope.unlockAccount = function() {
		var data = $.param({
			address: $scope.address,
			password: $scope.password
		});
		
		var config = {
			headers : {
				'Content-Type': 'application/x-www-form-urlencoded'
			}
		};
		
		$http.post('/unlockAccount', data, config)
			.success(function (data, status, headers, config) {
				if (data) {
					$scope.showMessage = true;
				    $scope.messageType = "success";
					$scope.ResponseDetails = "Account unlocked successfully";
					$scope.address = null;
					$scope.password = null;
					$scope.commandId = null;
				}				
			})
			.error(function (data, status, header, config) {
				$scope.showMessage = true;
				$scope.messageType = "warning";
				$scope.ResponseDetails = "Error on unlocking your account, address or passphrase invalid.";
			});
   };
   
   // if user is running mozilla then use it's built-in WebSocket
  window.WebSocket = window.WebSocket || window.MozWebSocket;

  var connection = new WebSocket('wss://localhost:443', 'echo-protocol');
  // var connection = new WebSocket('wss://ec2-35-176-165-139.eu-west-2.compute.amazonaws.com:443', 'echo-protocol');

  connection.onopen = function () {
    // connection is opened and ready to use
	console.log('client opened socket');
  };

  connection.onerror = function (error) {
    // an error occurred when sending/receiving data
   console.log('err: '+error);
  };

  connection.onmessage = function (message) {
    // try to decode json (I assume that each message
    // from server is json)
	console.log('server response:'+message);
    try {
	  var json = JSON.parse(message.data);
	  // save client id on first connection
	  $scope.client_uuid = json.id;
	  console.log(json);
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
   data: [1,2,3]
   }));
  };
  
});
