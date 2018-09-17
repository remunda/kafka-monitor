# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM anapsix/alpine-java:8_jdk as build
ARG CODE_VERSION
WORKDIR /src
RUN apk add git && git clone --branch master https://github.com/linkedin/kafka-monitor.git 
WORKDIR /src/kafka-monitor
RUN echo ${CODE_VERSION:=$(git tag | tail -1)} && git checkout $CODE_VERSION
RUN ./gradlew jar


FROM anapsix/alpine-java as final

MAINTAINER coffeepac@gmail.com

WORKDIR /opt/kafka-monitor
COPY --from=build /src/kafka-monitor/build/ build/ 
COPY --from=build /src/kafka-monitor/bin/kafka-monitor-start.sh bin/kafka-monitor-start.sh

COPY --from=build /src/kafka-monitor/bin/kmf-run-class.sh bin/kmf-run-class.sh
COPY --from=build /src/kafka-monitor/config/kafka-monitor.properties config/kafka-monitor.properties
COPY --from=build /src/kafka-monitor/config/log4j.properties config/log4j.properties
COPY --from=build /src/kafka-monitor/docker/kafka-monitor-docker-entry.sh kafka-monitor-docker-entry.sh
COPY --from=build /src/kafka-monitor/webapp/ webapp/

CMD ["/opt/kafka-monitor/kafka-monitor-docker-entry.sh"]
