FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir git+https://github.com/BerryKuipers/mcp_services_radarr_sonarr.git

EXPOSE 3000

CMD ["radarr-sonarr-mcp", "start"]
