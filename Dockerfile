FROM osrm/osrm-backend

# 1. Use archived Debian repositories
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

# 2. Install wget from working repos
RUN apt-get update && apt-get install -y wget

# 3. Download Chennai map (smaller file for free tier)
RUN wget https://download.openstreetmap.fr/extracts/asia/india/tamil_nadu/chennai.osm.pbf

# 4. Process map with optimizations for free tier constraints
RUN osrm-extract -p /opt/car.lua chennai.osm.pbf && \
    osrm-partition chennai.osm.pbf && \
    osrm-customize chennai.osm.pbf

# 5. Start server with memory optimizations
EXPOSE 5000
CMD ["osrm-routed", "--algorithm", "mld", "chennai.osm.pbf", "--max-matching-size", "8192", "--max-table-size", "8192"]
