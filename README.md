# alpine-solr
put archive solr-8.5.0.tgz here to build docker
(get solr from https://archive.apache.org/dist/lucene/solr/)

based on alpine 3.10 and opnejdk8-jre and solr 8.5.0

to run:

docker run -[td] -p 8983:8983 -e TINI no $docker_name:$tag

aslo you can use volume for /var/solr , but firstly you need to save contents /var/solr/data from container


