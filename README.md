# Graylog 3.3 with Content-Packs installer

Graylog 3.3 Container having a script to install content packs.
Content Packs can be placed in the `bootstrap/content-packs` Folder and installed
using the `bootstrap/install-content-packs.sh` script.

This has been forked from https://github.com/kimble/graylog2-docker which already contained most of the work.
The majority of changes are to make the script compatible with the Graylog3 REST API.

# Usage

As I intended this Container only for local dev use, I only run it with a _docker-compose_ file like the following.
The Bootstrap folder is *not* copied to the actual container but only mapped via the _docker-compose_ file's volume entries.

```yaml
version: '3'
services:
    graylog:
        image: graylog33
        build:
            context: docker/graylog
        volumes:
            - graylog_data:/usr/share/graylog/data
            - "./docker/graylog/config:/usr/share/graylog/data/config"
            - "./docker/graylog/bootstrap:/bootstrap"
        environment:
            # admin/admin
            - GRAYLOG_ROOT_PASSWORD_SHA2=8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918
            - GRAYLOG_PASSWORD_SECRET=eadee2eis3ahzukeoph6Outh8HieW3aibahW9Gail6ISh5thoughiveihis0taev
            - GRAYLOG_HTTP_EXTERNAL_URI=http://localhost:9000/
        depends_on:
            - mongo
            - elasticsearch
        ports:
            # Graylog web interface and REST API
            - 9000:9000
            # Syslog TCP
#            - 1514:1514
            # Syslog UDP
#            - 1514:1514/udp
            # GELF TCP
#            - 12201:12201
            # GELF UDP
            - 12201:12201/udp

    mongo:
        image: mongo:3
        volumes:
            - mongo_data:/data/db

    elasticsearch:
        image: docker.elastic.co/elasticsearch/elasticsearch-oss:6.8.10
        volumes:
            - es_data:/usr/share/elasticsearch/data
        environment:
            - http.host=0.0.0.0
            - transport.host=localhost
            - network.host=0.0.0.0
            - "ES_JAVA_OPTS=-Xms512m -Xmx512m"

volumes:
    mongo_data:
        driver: local
    es_data:
        driver: local
    graylog_data:
        driver: local
```
