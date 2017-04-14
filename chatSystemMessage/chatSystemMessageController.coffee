_ = require 'lodash'
moment = require 'moment'

module.exports = class chat_system_message_controller

  @inject = ['$scope', 'RequestsFieldsTranslator', 'Branches', 'RequestStates', 'Priorities', '$q']

  constructor: (@$scope, RequestsFieldsTranslator, @Branches, @RequestStates, @Priorities, @$q)->
    @RFT = RequestsFieldsTranslator
    @roles = @$scope.roles
    @comment = @$scope.model
    @fields = @$scope.fields
    @items = []

    @$q.all
      branches: @Branches.getList()
      states: @RequestStates.getList()
      priorities: @Priorities.getList()
    .then (res) =>
      @branch_collection = _.keyBy res.branches, 'code'
      @priority_collection = _.keyBy res.priorities, 'code'
      @state_collection = _.keyBy res.states, 'code'

      for p of @comment.fields

        to = @comment.fields[p].to
        from = @comment.fields[p].from

        if p is 'complete_at' and @comment.fields[p].from?
          from = moment(@comment.fields[p].from).format 'DD.MM.YYYY'
        if p is 'priority'
          from = @priority_collection[@comment.fields[p].from].name
          to = @priority_collection[@comment.fields[p].to].name
        if p is 'state'
          from = @state_collection[@comment.fields[p].from].name
          to = @state_collection[@comment.fields[p].to].name
        if p is 'branch'
          from = @branch_collection[@comment.fields[p].from].name
          to = @branch_collection[@comment.fields[p].to].name

        if from == null then from = "\"пусто\""

        adding =
          from: from
          to: to
          name: @RFT.translate p

        @items.push adding
