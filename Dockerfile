FROM osrm/osrm-backend

# Install dependencies
RUN apt-get update && apt-get install -y wget

# Download Tamil Nadu map from reliable mirror (18MB)
RUN wget https://download.openstreetmap.fr/extracts/asia/india/tamil_nadu.osm.pbf

# Process the map (faster with small component removal)
RUN osrm-extract -p /opt/car.lua tamil_nadu.osm.pbf --small-component-size 1
RUN osrm-partition tamil_nadu.osm.pbf
RUN osrm-customize tamil_nadu.osm.pbf
CMD ["osrm-routed", "--algorithm", "mld", "tamil_nadu.osm.pbf"]
