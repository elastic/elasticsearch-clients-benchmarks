# $ docker build  --tag elastic/elasticsearch-clients-benchmarks-data .
#
# $ docker run -it --rm elastic/elasticsearch-clients-benchmarks-data cat /benchmarks-data/small/document.json
#
# $ docker tag elastic/elasticsearch-clients-benchmarks-data eu.gcr.io/elastic-clients/benchmarks-data
#
# $ docker push eu.gcr.io/elastic-clients/benchmarks-data
#

FROM alpine

COPY . /benchmarks-data
