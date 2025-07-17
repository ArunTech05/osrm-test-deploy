FROM osrm/osrm-backend:latest

RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list && \
    apt-get -o Acquire::Check-Valid-Until=false update && \
    apt-get install -y wget osmium-tool

# ✅ Correct Southern Zone file
RUN wget https://download.geofabrik.de/asia/india/southern-zone-latest.osm.pbf -O southern-zone.osm.pbf

# ✅ Extract Ramanathapuram only (optional)
RUN echo "ramanathapuram" > ramanathapuram.poly && \
    echo "1" >> ramanathapuram.poly && \
    echo "78.35 9.05" >> ramanathapuram.poly && \
    echo "79.00 9.05" >> ramanathapuram.poly && \
    echo "79.00 9.60" >> ramanathapuram.poly && \
    echo "78.35 9.60" >> ramanathapuram.poly && \
    echo "END" >> ramanathapuram.poly && \
    echo "END" >> ramanathapuram.poly && \
    osmium extract -p ramanathapuram.poly southern-zone.osm.pbf -o ramanathapuram.osm.pbf

RUN osrm-extract -p /opt/car.lua ramanathapuram.osm.pbf && \
    osrm-partition ramanathapuram.osm.pbf && \
    osrm-customize ramanathapuram.osm.pbf

EXPOSE 5000
CMD ["osrm-routed", "--algorithm", "mld", "ramanathapuram.osm.pbf"]
