FROM osrm/osrm-backend

# 1. Use archived Debian repositories
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

# 2. Install wget from working repos
RUN apt-get update && apt-get install -y wget

# 3. Download Chennai map (smaller file for free tier)
RUN wget https://download.openstreetmap.fr/extracts/asia/india/tamil_nadu/chennai.osm.pbf

# 4. Process map with optimizations
RUN osrm-extract -p /opt/car.lua chennai.osm.pbf --small-component-size 1
RUN osrm-partition chennai.osm.pbf
RUN osrm-customize chennai.osm.pbf

# 5. Start server
CMD ["osrm-routed", "--algorithm", "mld", "chennai.osm.pbf"]
