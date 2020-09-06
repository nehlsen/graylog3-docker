FROM graylog/graylog:3.3

USER root
RUN apt-get update && apt-get install -y jq
RUN apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

USER graylog
