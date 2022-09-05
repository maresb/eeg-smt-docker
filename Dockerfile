FROM ubuntu:22.04@sha256:34fea4f31bf187bc915536831fd0afc9d214755bf700b5cdb1336c82516d154e AS ns-build

RUN : \
  && apt-get update && apt-get install --no-install-recommends -y \
    autoconf \
    automake \
    build-essential \
  && rm -rf /var/lib/apt/lists/* \
;

COPY NeuroServer-0.7.4/ /usr/src/NeuroServer-0.7.4/
WORKDIR /usr/src/NeuroServer-0.7.4/

RUN aclocal && autoconf && automake -a && ./configure
RUN make

FROM ubuntu:22.04@sha256:34fea4f31bf187bc915536831fd0afc9d214755bf700b5cdb1336c82516d154e AS nsd-target

COPY --from=ns-build /usr/src/NeuroServer-0.7.4/src/nsd /usr/local/bin/nsd

RUN groupadd -r nsduser && useradd --no-log-init -r -g nsduser nsduser
USER nsduser

FROM ubuntu:22.04@sha256:34fea4f31bf187bc915536831fd0afc9d214755bf700b5cdb1336c82516d154e AS modeegdriver-target

COPY --from=ns-build /usr/src/NeuroServer-0.7.4/src/modeegdriver /usr/local/bin/modeegdriver
COPY run-modeegdriver.sh /usr/local/bin/run-modeegdriver.sh

# FROM dkimg/opencv:4.6.0-alpine@sha256:df34f01f02af2c00661d4d6b0c8f6fc2a3c5ee18fcf9945af280db9a117af3c5 AS plot-target
FROM python:3.10.6-buster@sha256:25cfebf4cb288eefaa86ee886fb82d26a72fadea64b8c5a9287de2fb1c6ead72 AS plot-target
RUN : \
  && apt-get update && apt-get install --no-install-recommends -y \
    libgl1 \
  && rm -rf /var/lib/apt/lists/* \
;
RUN pip install opencv-python==4.6.0.66

RUN groupadd -r plotuser -g 999 && useradd --no-log-init -r -g plotuser plotuser
USER plotuser

COPY plot.py /usr/src/
WORKDIR /usr/src/

CMD python plot.py
