FROM osrm/osrm-backend

# 1. Use archived Debian repositories
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

# 2. Install wget
RUN apt-get update && apt-get install -y wget

# 3. Download a small Chennai map (fits free-tier RAM)
RUN wget http://download.bbbike.org/osm/bbbike/Chennai/Chennai.osm.pbf -O chennai.osm.pbf

# 4. Process map
RUN osrm-extract -p /opt/car.lua chennai.osm.pbf && \
    osrm-partition chennai.osm.pbf && \
    osrm-customize chennai.osm.pbf

# 5. Start with memory optimizations
EXPOSE 5000
CMD ["osrm-routed", "--algorithm", "mld", "chennai.osm.pbf", "--max-matching-size", "512", "--max-table-size", "512", "--threads", "2"]
