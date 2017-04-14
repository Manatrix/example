controller = require './chatSystemMessageController'

module.exports = () ->
  replace: true
  template: require './chatSystemMessage.haml'
  controller: controller
  controllerAs: 'sys_chat_mes'
  scope:
    model:'='
    fields:'='
    roles:'='

