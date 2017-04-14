_ = require 'lodash'
module.exports = class filterMultController
  @inject = ['$q', '$scope', 'Brands', 'Buildings', 'Cities', 'Stores', 'Identity']
  constructor: (@$q, @$scope, @Brands, @Buildings, @Cities, @Stores, @Identity)->
    @model = @$scope.model
    @roleCheck()
    .then =>
      @request()


  cityChange: ->
    @model.brand_ids = []
    @model.building_ids = []
    @model.store_ids = []
    @buildings = []
    @stores = []
    @brands = []
    building_ids = []
    brand_ids = []
    currentBuildings = []
    currentStores = []
    currentBrands = []
    city_ids = @model.city_ids
    if city_ids.length isnt 0
      for c in city_ids
        currentBuildings = _.filter(@allBuildings, ['city_id', c])
        for b in currentBuildings
          @buildings.push(b)
    else
      @buildings = @allBuildings

    for b in @buildings
      building_ids.push(b.id)
    for b in building_ids
      currentStores = _.filter(@allStores, ['building_id', b])
      for s in currentStores
        @stores.push(s)
    @cityStores = @stores

    for s in @stores
      brand_ids.push(s.brand_id)
    for b in brand_ids
      currentBrands = _.filter(@allBrands, ['id', b])
      for br in currentBrands
        @brands.push(br)
    @brands = _.uniq(@brands)
    @cityBrands = @brands

    setTimeout @reloadPicker, 0


  buildingChange: ->
    if @model.city_ids is null
      @cityStores = @allStores
      @cityBrands = @allBrands
    @model.store_ids = []
    @model.brand_ids = []
    @brands = []
    @stores = []
    brand_ids = []
    building_ids = @model.building_ids
    if building_ids.length isnt 0
      for b in building_ids
        currentStores = _.filter(@cityStores, ['building_id', b])
        for s in currentStores
          @stores.push(s)
    else @stores = @cityStores
    @buildingStores = @stores

    for s in @stores
      brand_ids.push(s.brand_id)
    for b in brand_ids
      currentBrands = _.filter(@cityBrands, ['id', b])
      for br in currentBrands
        @brands.push(br)
    @brands = _.uniq(@brands)

    setTimeout @reloadPicker, 0


  brandChange: ->
    if @model.building_ids is null
      @buildingStores = @cityStores
    @model.store_ids = []
    @stores = []
    brand_ids = @model.brand_ids
    if brand_ids.length isnt 0
      for b in brand_ids
        currentStores = _.filter(@buildingStores, ['brand_id', b])
        for s in currentStores
          @stores.push(s)
    else @stores = @buildingStores
    setTimeout @reloadPicker, 0


  request: ->
    if @isagent
      @Stores.getList agent_ids: @agent_id
      .then (res) =>
        @stores = _.keyBy res, 'id'
        @building_ids = (_.uniq _.map res, 'building_id').join(',')
        @brand_ids = (_.uniq _.map res, 'brand_id').join(',')
        @$q.all
          brands: @Brands.getList(ids: @brand_ids)
          buildings: @Buildings.getList(ids: @building_ids)
        .then (res) =>
          @allBrands = @brands = _.keyBy res.brands, 'id'
          @buildings = _.keyBy res.buildings, 'id'
          @city_ids = (_.uniq _.map res.buildings, 'city_id').join(',')
          @Cities.getList(ids: @city_ids)
          .then (res) =>
            @cities = _.keyBy res, 'id'
            @storesCreate @stores
            @buildingsCreate @buildings
            setTimeout @reloadPicker, 0
    else if @ispartner
      @Brands.getList company_id: @company_id
      .then (res) =>
        @allBrands = @brands = _.keyBy res, 'id'
        @brand_ids = (_.uniq _.map res, 'id').join(',')
        @Stores.getList brand_ids: @brand_ids
        .then (res) =>
          @stores = _.keyBy res, 'id'
          @building_ids = (_.uniq _.map res, 'building_id').join(',')
          @Buildings.getList(ids: @building_ids)
          .then (res) =>
            @buildings = _.keyBy res, 'id'
            @city_ids = (_.uniq _.map res, 'city_id').join(',')
            @Cities.getList(ids: @city_ids)
            .then (res) =>
              @cities = _.keyBy res, 'id'
              @storesCreate @stores
              @buildingsCreate @buildings
              setTimeout @reloadPicker, 0
    else
      @$q.all
        cities: @Cities.getList()
        buildings: @Buildings.getList()
        brands: @Brands.getList()
        stores: @Stores.getList()
      .then (res) =>
        @cities = _.keyBy res.cities, 'id'
        @buildings = _.keyBy res.buildings, 'id'
        @allBrands = @brands = _.keyBy res.brands, 'id'
        @stores = _.keyBy res.stores, 'id'
        @storesCreate @stores
        @buildingsCreate @buildings
        setTimeout @reloadPicker, 0


  buildingsCreate: (buildings) ->
    for p of buildings
      buildings[p].city_name = @cities[buildings[p].city_id].name
      buildings[p].building_name = buildings[p].name
    @allBuildings = @buildings = _.sortBy buildings, 'building_name', 'city_name'

  storesCreate: (stores) ->
    for p of stores
      stores[p].brand_name = @brands[stores[p].brand_id].name
      stores[p].building_name = @buildings[stores[p].building_id].name
      stores[p].store_code = stores[p].code
      stores[p].city_name = @cities[@buildings[stores[p].building_id].city_id].name
    @allStores = @stores = _.sortBy stores, 'brand_name', 'city_name', 'building_name', 'store_code'

  roleCheck: ->
    @Identity
    .getData()
    .then (result) =>
      @role = result.role
      if @role is 'agent'
        @agent_id = result.id
        @isagent = true
      else if @role is 'partner'
        @company_id = result.company_id
        @ispartner = true

  reloadPicker: ->
    $('.selectpicker_dir').selectpicker('destroy')
    $('.selectpicker_dir').selectpicker()
    $(".bootstrap-select").click(->
      $(this).addClass("open")
    )
    $('.selectpicker_dir').selectpicker('render')

