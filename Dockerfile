FROM osrm/osrm-backend

# Use archived Debian repositories
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y wget

# Download and process map
RUN wget https://download.geofabrik.de/asia/india/tamil-nadu-latest.osm.pbf
RUN osrm-extract -p /opt/car.lua tamil-nadu-latest.osm.pbf
RUN osrm-partition tamil-nadu-latest.osm.pbf
RUN osrm-customize tamil-nadu-latest.osm.pbf
CMD ["osrm-routed", "--algorithm", "mld", "tamil-nadu-latest.osm.pbf"]
