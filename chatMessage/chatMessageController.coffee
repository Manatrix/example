module.exports = class chat_message_controller
  @inject = ['$scope']
  constructor: (@$scope)->
    @roles = @$scope.roles
    @comment = @$scope.model

#    console.log 'chat_system_message roles', @roles