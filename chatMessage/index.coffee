controller = require './chatMessageController'

module.exports = () ->
  replace: true
  template: require './chatMessage.haml'
  controller: controller
  controllerAs: 'chat_mes'
  scope:
    model:'='
    roles:'='

