#-----------------------------------------------------------------------------------------------------------------------
#' everybody loves maps : haute route
#' 
#' author:          cat eisenhauer
#' date created:    july 2023
#' 
#-----------------------------------------------------------------------------------------------------------------------

library(leaflet)
library(htmlwidgets)


sf::st_layers(here::here('data', 'haute-route.gpx'))

sites <- sf::st_read(here::here('data', 'haute-route.gpx'),
										 layer = 'waypoints') %>%
  dplyr::select(ele, name, geometry) %>%
  dplyr::mutate(popup = paste0('<b>', name,'</b><br>Elevation: ', ele))

#trace_raw <- sf::st_read(here::here('data', 'haute-route.gpx'),
												 #layer = 'track_points')

#trace <- trace_raw %>%
  #sf::st_combine() %>%
  #sf::st_cast(to = 'LINESTRING') %>%
  #sf::st_sf()


trace <- sf::st_read(here::here('data', 'haute-route.gpx'),
												 layer = 'tracks')


map <- leaflet() %>%
  # add tiles
  addProviderTiles("OpenStreetMap.Mapnik", group = "Basic") %>%
  addProviderTiles("OpenTopoMap", group = "Topographical") %>%
  addProviderTiles("Esri.WorldImagery", group = "Satellite") %>%

  # layer control
  addLayersControl(position = "bottomright",
    baseGroups = c("Basic", "Topographical", "Satellite"),
    overlayGroups = c("Trail", "Campsites"),
    options = layersControlOptions(collapsed = FALSE)) %>%

	# add trail
  addPolylines(data = trace,
							 color = "red",
							 opacity = 1,
							 group = "Trail") %>%

	# add campsites
	addAwesomeMarkers(data = sites,
										popup = sites$popup,
										icon = makeAwesomeIcon(icon = 'tent',
																					 markerColor = 'red'),
										group = 'Campsites') %>%

	# add ruler to measure distances
  addMeasure() 

map

htmlwidgets::saveWidget(map,
												file = "haute-route.html",
												selfcontained = TRUE)
