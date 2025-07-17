FROM osrm/osrm-backend

# 1. Install required tools (osmium & wget)
RUN apt-get update && apt-get install -y wget osmium-tool

# 2. Download full Tamil Nadu map
RUN wget https://download.geofabrik.de/asia/india/tamil-nadu-latest.osm.pbf -O tamil_nadu.osm.pbf

# 3. Download Ramanathapuram boundary polygon (.poly)
RUN wget https://download.geofabrik.de/asia/india/tamil-nadu.poly -O tamil_nadu.poly

# 4. Extract Ramanathapuram district from Tamil Nadu map
# (osmium will cut only the area that matches the polygon boundary)
RUN osmium extract -p tamil_nadu.poly --with-history tamil_nadu.osm.pbf -o ramanathapuram.osm.pbf

# 5. Process the Ramanathapuram map (optimized for low memory)
RUN osrm-extract -p /opt/car.lua ramanathapuram.osm.pbf && \
    osrm-partition ramanathapuram.osm.pbf && \
    osrm-customize ramanathapuram.osm.pbf

# 6. Expose port and run OSRM server
EXPOSE 5000
CMD ["osrm-routed", "--algorithm", "mld", "ramanathapuram.osrm", "--max-matching-size", "512", "--max-table-size", "512", "--threads", "2"]
