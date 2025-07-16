FROM osrm/osrm-backend:latest

# 1. Fix Debian repositories first
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

# 2. Install wget using working repos
RUN apt-get update && apt-get install -y wget

# 3. Download a SMALL TEST MAP (Manhattan - replace later)
RUN wget https://download.geofabrik.de/north-america/us/new-york-latest.osm.pbf

# 4. Fast processing (test mode)
RUN osrm-extract -p /opt/car.lua new-york-latest.osm.pbf --small-component-size 1
RUN osrm-partition new-york-latest.osm.pbf
RUN osrm-customize new-york-latest.osm.pbf
CMD ["osrm-routed", "--algorithm", "mld", "new-york-latest.osm.pbf"]
