import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "unread" ]

  connect() {
    this.load()
    this.setUnread(this.data.get("unread"))
    this.handleZero(this.getUnread())
    window.notificationsController = this
  }

  increment() {
    this.setUnread(this.getUnread() + 1)
    this.handleZero( this.getUnread() )
  }

  decrement() {
    this.setUnread(this.getUnread() - 1)
    this.handleZero( this.getUnread() )
  }

  handleZero(value) {
    if(value > 0) {
      $('#notifications > #empty_notice').addClass('d-none')
      this.unreadTarget.classList.remove('d-none')
    } else {
      $('#notifications > #empty_notice').removeClass('d-none')
      this.unreadTarget.classList.add('d-none')
    }
  }

  getUnread() {
    return parseInt(this.data.get("unread"))
  }

  setUnread(value) {
    this.data.set("unread", value)
    this.unreadTarget.innerHTML = value
  }

  getVisibleCount() {
    return document.querySelectorAll("#notifications .dropdown-item").length
  }

  load() {
    Rails.ajax({
      type: "get",
      url: this.data.get("url"),
      beforeSend: function() {
        return true;
      },
      success: function(response) {
        document.querySelector('[data-target="notifications.container"]').innerHTML = response.body.innerHTML
      },
      error: function(response) {
        console.log(`Notifications failed to load: ${response}`)
      }
    })
  }

  addNotification(data) {
    $("#notifications").prepend(data.html)
    this.increment()
    var audio = new Audio('/sounds/notification.mp3')
    audio.play()
    $("#notifications").timeago()
  }

  removeNotification(id) {
    $('#notifications > #notification_' + id).detach()
    this.decrement()
    // so slow...
    if (this.getVisibleCount() < 8 && this.getUnread() > 8) {
      this.load()
    }
  }
}
