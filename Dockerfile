FROM osrm/osrm-backend:latest

# 1. Use archived Stretch repos & install tools
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list && \
    apt-get -o Acquire::Check-Valid-Until=false update && \
    apt-get install -y wget osmium-tool

# 2. Download Southern Zone map (includes Tamil Nadu)
RUN wget https://download.geofabrik.de/asia/india/southern-zone-latest.osm.pbf -O southern-zone.osm.pbf

# 3. Extract Ramanathapuram district using approximate polygon
RUN echo "ramanathapuram" > ramanathapuram.poly && \
    echo "1" >> ramanathapuram.poly && \
    echo "78.35 9.05" >> ramanathapuram.poly && \
    echo "79.00 9.05" >> ramanathapuram.poly && \
    echo "79.00 9.60" >> ramanathapuram.poly && \
    echo "78.35 9.60" >> ramanathapuram.poly && \
    echo "END" >> ramanathapuram.poly && \
    echo "END" >> ramanathapuram.poly && \
    osmium extract -p ramanathapuram.poly southern-zone.osm.pbf -o ramanathapuram.osm.pbf

# 4. Process the Ramanathapuram map
RUN osrm-extract -p /opt/car.lua ramanathapuram.osm.pbf && \
    osrm-partition ramanathapuram.osm.pbf && \
    osrm-customize ramanathapuram.osm.pbf

# 5. Run with memory-optimized settings
EXPOSE 5000
CMD ["osrm-routed", "--algorithm", "mld", "ramanathapuram.osm.pbf", "--max-matching-size", "512", "--max-table-size", "512", "--threads", "2"]
