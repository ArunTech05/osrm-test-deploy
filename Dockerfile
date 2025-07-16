FROM osrm/osrm-backend
RUN wget https://download.geofabrik.de/asia/india/tamil-nadu-latest.osm.pbf
RUN osrm-extract -p /opt/car.lua tamil-nadu-latest.osm.pbf
RUN osrm-partition tamil-nadu-latest.osm.pbf
RUN osrm-customize tamil-nadu-latest.osm.pbf
CMD ["osrm-routed", "--algorithm", "mld", "tamil-nadu-latest.osm.pbf"]
