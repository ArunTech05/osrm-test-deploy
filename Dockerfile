FROM osrm/osrm-backend

# Install dependencies
RUN apt-get update && apt-get install -y wget

# Download India map (smaller Tamil Nadu extract for free tier)
RUN wget https://download.openstreetmap.fr/extracts/asia/india/tamil_nadu.osm.pbf

# Process map (optimized for low-memory)
RUN osrm-extract -p /opt/car.lua tamil_nadu.osm.pbf --small-component-size 1
RUN osrm-partition tamil_nadu.osm.pbf
RUN osrm-customize tamil_nadu.osm.pbf

# Start server
CMD ["osrm-routed", "--algorithm", "mld", "tamil_nadu.osm.pbf"]
