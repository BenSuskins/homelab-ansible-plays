FROM python:3.11-slim

RUN pip install --no-cache-dir git+https://github.com/BerryKuipers/mcp_services_radarr_sonarr.git

EXPOSE 3000

CMD ["radarr-sonarr-mcp", "start"]
