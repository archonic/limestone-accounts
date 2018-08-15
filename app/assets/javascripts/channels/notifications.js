if ( document.head.querySelector('meta[name="current-user"]') ) {
  App.notifications = App.cable.subscriptions.create("NotificationsChannel", {
    connected: function() {
      // Called when the subscription is ready for use on the server
      console.log("CONNECTED");
    },

    disconnected: function() {
      // Called when the subscription has been terminated by the server
      console.log("DISCONNECTED");
    },

    received: function(data) {
      // Called when there's incoming data on the websocket for this channel
      switch(data.action){
        case "create":
          notificationsController.addNotification(data);
          break;
        case "read":
          notificationsController.removeNotification(data.id);
      }
    }
  });
}
