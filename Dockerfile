FROM fluent/fluentd:v1.12
USER root
# below RUN includes plugin as examples elasticsearch is not required
# you may customize including plugins as you wish

RUN apk add --update krb5-libs snappy && \
    apk add --update --virtual .build-deps libffi-dev \
        sudo build-base ruby-dev snappy-dev build-base libexecinfo automake autoconf libtool && \
    sudo gem install fluent-plugin-kafka \
                     fluent-plugin-influxdb \
                     fluent-plugin-rewrite-tag-filter \
                     fluent-plugin-record-modifier \
                     activesupport:7.0.3 \
                     fluent-plugin-juniper-telemetry \
                     fluent-plugin-snmp \
                     elasticsearch:7.6.0 \
                     excon:0.92.3 \
                     faraday:1.10.0 \
                     fluent-plugin-elasticsearch:5.2.2 \
                     fluent-plugin-retag \
                     fluent-plugin-datadog \
                     bigdecimal \
                     zookeeper \
                     snappy \
                     extlz4 \
                     fluent-plugin-gelf-hs && \
    sudo gem sources --clear-all && \
    apk del .build-deps && \
    rm -rf /var/cache/apk/* \
           /usr/lib/ruby/gems/2.7.0/cache

ADD plugins /fluentd/plugins
