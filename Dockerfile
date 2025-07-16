FROM osrm/osrm-backend:v5.27.1

# 1. Install dependencies (using newer image version avoids repository issues)
RUN apt-get update && apt-get install -y wget

# 2. Download Chennai metro extract (smaller file for free tier)
RUN wget https://download.geofabrik.de/asia/india/south-latest.osm.pbf -O chennai.osm.pbf

# 3. Process map with optimizations for free tier constraints
RUN osrm-extract -p /opt/car.lua chennai.osm.pbf && \
    osrm-partition chennai.osm.pbf && \
    osrm-customize chennai.osm.pbf

# 4. Start server with aggressive memory optimizations
EXPOSE 5000
CMD ["osrm-routed", "--algorithm", "mld", "chennai.osm.pbf", "--max-matching-size", "2048", "--max-table-size", "2048"]
