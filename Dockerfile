FROM osrm/osrm-backend

# 1. Use archived Debian repositories
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

# 2. Install wget from working repos
RUN apt-get update && apt-get install -y wget

# 3. Download Tamil Nadu map from OSM.fr (working source)
RUN wget https://download.openstreetmap.fr/extracts/asia/india/tamil_nadu-latest.osm.pbf -O tamil_nadu.osm.pbf

# 4. Process map with optimizations for free tier constraints
RUN osrm-extract -p /opt/car.lua tamil_nadu.osm.pbf && \
    osrm-partition tamil_nadu.osm.pbf && \
    osrm-customize tamil_nadu.osm.pbf

# 5. Start server with memory optimizations
EXPOSE 5000
CMD ["osrm-routed", "--algorithm", "mld", "tamil_nadu.osm.pbf", "--max-matching-size", "4096", "--max-table-size", "4096"]
