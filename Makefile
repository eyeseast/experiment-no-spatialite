
DB = boston.db
APP = experiment-no-spatialite

GEOJSON = data/council-districts.geojson \
	data/cannabis.geojson \
	data/wifi.geojson

run:
	# https://docs.datasette.io/en/stable/settings.html#configuration-directory-mode
	pipenv run datasette serve .

data/council-districts.geojson:
	mkdir -p data
	wget -O $@ https://bostonopendata-boston.opendata.arcgis.com/datasets/boston::city-council-districts-effective-for-the-2023-municipal-election.geojson

data/cannabis.geojson:
	mkdir -p data
	wget -O $@ https://bostonopendata-boston.opendata.arcgis.com/datasets/boston::cannabis-registry.geojson

data/wifi.geojson:
	mkdir -p data
	wget -O $@ https://bostonopendata-boston.opendata.arcgis.com/datasets/boston::wicked-free-wifi-locations.geojson

tables: $(GEOJSON)
	pipenv run geojson-to-sqlite $(DB) districts data/council-districts.geojson --pk FID
	pipenv run geojson-to-sqlite $(DB) cannabis data/cannabis.geojson --pk ObjectId
	pipenv run geojson-to-sqlite $(DB) wifi data/wifi.geojson --pk ObjectId

deploy:
	pipenv run datasette publish fly $(DB) \
		--app $(APP) \
		--install datasette-geojson-map \
		--install shapely \
		--install sqlite-colorbrewer \
		-m metadata.yml \
		--plugins-dir plugins

open:
	fly open --app $(APP)
