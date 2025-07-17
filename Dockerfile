FROM osrm/osrm-backend:latest

# ✅ 1. Switch to archived Debian Stretch repositories
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list && \
    apt-get -o Acquire::Check-Valid-Until=false update && \
    apt-get install -y wget osmium-tool

# ✅ 2. Download full Tamil Nadu map
RUN wget https://download.geofabrik.de/asia/india/tamil-nadu-latest.osm.pbf -O tamil_nadu.osm.pbf

# ✅ 3. Create Ramanathapuram boundary (manual .poly file)
RUN echo "ramanathapuram" > ramanathapuram.poly && \
    echo "1" >> ramanathapuram.poly && \
    echo "  78.35 9.05" >> ramanathapuram.poly && \
    echo "  79.00 9.05" >> ramanathapuram.poly && \
    echo "  79.00 9.60" >> ramanathapuram.poly && \
    echo "  78.35 9.60" >> ramanathapuram.poly && \
    echo "END" >> ramanathapuram.poly && \
    echo "END" >> ramanathapuram.poly

# ✅ 4. Extract only Ramanathapuram region
RUN osmium extract -p ramanathapuram.poly tamil_nadu.osm.pbf -o ramanathapuram.osm.pbf

# ✅ 5. Process Ramanathapuram map (low memory optimized)
RUN osrm-extract -p /opt/car.lua ramanathapuram.osm.pbf && \
    osrm-partition ramanathapuram.osm.pbf && \
    osrm-customize ramanathapuram.osm.pbf

# ✅ 6. Expose and run OSRM
EXPOSE 5000
CMD ["osrm-routed", "--algorithm", "mld", "ramanathapuram.osrm", "--max-matching-size", "512", "--max-table-size", "512", "--threads", "2"]
