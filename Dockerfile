FROM osrm/osrm-backend
# First install wget and dependencies
RUN apt-get update && apt-get install -y wget
# Then download and process the map
RUN wget https://download.geofabrik.de/asia/india/tamil-nadu-latest.osm.pbf
RUN osrm-extract -p /opt/car.lua tamil-nadu-latest.osm.pbf
RUN osrm-partition tamil-nadu-latest.osm.pbf
RUN osrm-customize tamil-nadu-latest.osm.pbf
CMD ["osrm-routed", "--algorithm", "mld", "tamil-nadu-latest.osm.pbf"]
