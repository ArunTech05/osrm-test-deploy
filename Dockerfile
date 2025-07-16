FROM osrm/osrm-backend

# Use archived Debian repositories
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y wget

# Download and process a smaller Chennai map (verified working URL)
RUN wget https://download.geofabrik.de/asia/india/tamil-nadu/chennai-latest.osm.pbf
RUN osrm-extract -p /opt/car.lua chennai-latest.osm.pbf
RUN osrm-partition chennai-latest.osm.pbf
RUN osrm-customize chennai-latest.osm.pbf
CMD ["osrm-routed", "--algorithm", "mld", "chennai-latest.osm.pbf"]
