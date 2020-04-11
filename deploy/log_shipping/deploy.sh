if ${LOGS_SHIPPING_ENABLED}; then
    ./bin/ytt \
        -f app/loki/ \
    | ./bin/kapp deploy --app loki --file - --yes
fi
