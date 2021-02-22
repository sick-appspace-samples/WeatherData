--[[----------------------------------------------------------------------------

  Application Name:
  WeatherData

  Summary:
  Calculates meta information and smoothes weather data

  Description:
  Explains how to postprocess graph data and how to calculate meta information
  like minima and maxima using the profile api.

  How to run:
  Starting this sample is possible either by running the app (F5) or
  debugging (F7+F10). Setting breakpoint on the first row inside the 'main'
  function allows debugging step-by-step after 'Engine.OnStarted' event.
  Results can be seen in the image viewer on the DevicePage.
  To run this sample a device with SICK Algorithm API and AppEngine 2.5 or higher is necessary.
  For example InspectorP or SIM4000 with latest firmware. Alternatively the
  Emulator on AppStudio 2.3 or higher can be used.

  More Information:
  Tutorial "Algorithms - Profile - FirstSteps".

------------------------------------------------------------------------------]]

--Start of Global Scope---------------------------------------------------------

local data = require 'data' -- contains the wheather data of Waldkirch(DE) from 2017

local xRange = {0, 364}
local yRange = {-20, 40}

local RAW_DATA_COLOR = {59, 156, 208}
local SMOOTH_DATA_COLOR = {242, 145, 0}
local AXIS_COLOR = {200, 200, 200}
local GRID_COLOR = {230, 230, 230}
local DARK_BLUE = {50, 50, 150, 255}
local DARK_RED = {150, 0, 0, 255}
local PURPLE = {150, 0, 150}
local TRANSPARENT = {0, 0, 0, 0}

local TEXT_COLOR = {0, 0, 0}
local LEGEND_SIZE = 4

local function getTextDeco(rgba, size, x, y)
  rgba[4] = rgba[4] or 255
  local deco = View.TextDecoration.create()
  deco:setColor(rgba[1], rgba[2], rgba[3], rgba[4])
  deco:setSize(size)
  deco:setPosition(x, y)
  return deco
end

local function getShapeDeco(rgbaVector, lineWidth, pointSize)

  lineWidth = lineWidth or 1
  pointSize = pointSize or 3
  rgbaVector[4] = rgbaVector[4] or 255

  local deco = View.ShapeDecoration.create()
  deco:setLineColor(rgbaVector[1], rgbaVector[2], rgbaVector[3], rgbaVector[4]) -- grey
  deco:setFillColor(rgbaVector[1], rgbaVector[2], rgbaVector[3], rgbaVector[4])
  deco:setLineWidth(lineWidth)
  deco:setPointSize(pointSize)

  return deco
end

local function getGraphDeco(rgba, size, isOverlay, graphType)
  size = size or 0
  graphType = graphType or 'LINE'
  isOverlay = isOverlay or false
  local deco = View.GraphDecoration.create()
  deco:setGraphColor(table.unpack(rgba))
  deco:setXBounds(table.unpack(xRange))
  deco:setYBounds(table.unpack(yRange))
  deco:setAxisColor(table.unpack(AXIS_COLOR))
  deco:setGridColor(table.unpack(GRID_COLOR))
  deco:setLabelColor(table.unpack(TEXT_COLOR))
  deco:setDrawSize(size)
  deco:setAxisVisible(not isOverlay)
  deco:setBackgroundVisible(not isOverlay)
  deco:setGridVisible(not isOverlay)
  deco:setTicksVisible(not isOverlay)
  deco:setLabelsVisible(not isOverlay)
  deco:setAspectRatio('EQUAL')
  deco:setGraphType(graphType)
  deco:setDynamicSizing(true)
  deco:setAxisWidth(2)
  if not isOverlay then
    deco:setLabels('Days', '°C')
    deco:setTitle('Mean Temperature of Waldkirch in 2017')
    deco:setTitleSize(6)
  end
  return deco
end

local function addLegend(view, text, pointDeco, x, y)
  --draw legend
  view:addShape(Shape.createRectangle(Point.create(x, y), 2, 2), pointDeco)
  view:addText(text, getTextDeco(TEXT_COLOR, LEGEND_SIZE, x + 4, y - 2))
end

local function main()

  local temperatures = Profile.createFromVector(data['temperatures'])
  local days = data['days']
  local minTemp, indexMin = temperatures:getMin()
  local maxTemp, indexMax = temperatures:getMax()
  local meanTemp = temperatures:getMean()

  ------------------------------
  -- Display data --------------
  ------------------------------

  --create a background image to display stuff properly

  local viewer = View.create()
  viewer:clear()

  --draw raw temperature data
  viewer:addProfile(temperatures, getGraphDeco(RAW_DATA_COLOR), 'profile')

  --draw smooth temperature data
  viewer:addProfile(temperatures:gauss(31), getGraphDeco(SMOOTH_DATA_COLOR, 0, true))

  --draw mean temperature
  viewer:addProfile(
    Profile.createFromVector(
      {meanTemp, meanTemp},
      {temperatures:getCoordinate(0), temperatures:getCoordinate(temperatures:getSize() - 1)})
    , getGraphDeco(PURPLE, nil, true))

  --draw max temperature
  viewer:addShape(Point.create(temperatures:getCoordinate(indexMax), maxTemp), getShapeDeco(DARK_RED, 4), '', 'profile')

  --draw min temperature
  viewer:addShape(Point.create(temperatures:getCoordinate(indexMin), minTemp), getShapeDeco(DARK_BLUE, 4),'', 'profile')
  viewer:addProfile(temperatures, getGraphDeco(TRANSPARENT, 0, true))

  --draw legend
  addLegend(viewer, "Temperature", getShapeDeco(RAW_DATA_COLOR), days - 110, yRange[2] - 3)
  addLegend(viewer, "Temperature smoothed", getShapeDeco(SMOOTH_DATA_COLOR), days - 110, yRange[2] - 10)
  addLegend(viewer, "Max Temperature", getShapeDeco(DARK_RED), days - 40, yRange[2] - 3)
  addLegend(viewer, "Min Temperature", getShapeDeco(DARK_BLUE), days - 40, yRange[2] - 10)
  addLegend(viewer, "Mean Temperature", getShapeDeco(PURPLE), days - 40, yRange[2] - 17)

  viewer:present()

  --Print Information
  print('')
  print('Wheather of ' .. data['city'] .. ' from ' .. data['year'] .. ':')

  print('')
  print('Minimum Temperature: ' .. minTemp .. '°C')
  print('Maximum Temperature: ' .. maxTemp .. '°C')
  print('Mean Temperature:    ' .. meanTemp .. '°C')

  print('')
  print('Source: ' .. data['source'])
end
Script.register('Engine.OnStarted', main)
-- serve API in global scope
