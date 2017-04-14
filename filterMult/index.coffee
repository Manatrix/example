controller = require './filterMultController'

module.exports = () ->
  replace: true
  template: require './filterMult.haml'
  controller: controller
  controllerAs: 'filter_mult'
  scope:
    model:'='
