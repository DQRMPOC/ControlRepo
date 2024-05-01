## This script boots an instance of the rfavelocity feedhandler
## Currently must be run from the `cbin` directory of the feedhandler package


## Modify ../config/ExampleRFA.cfg to contain the correct RFA_HOST & RFA_PORT
## E.g.
# \Connections\Connection_RSSL\rsslPort                  = "14002"
# \Connections\Connection_RSSL\hostName                  = "localhost"

## Setup variables

## subscription list location
# contains one RIC on each line (no leading backtick)
FH_SUBSCRIPTION_LIST=../config/testSubList.txt 

### Asset Class Variables
FH_ASSET_CLASS=EQUITY
FH_FIELD_MAP=eqfieldmap.txt
FH_SCHEMA_FILE=rfavTREqSchema.xml

# exchange map package
FH_EXCHANGE_MAP_PACKAGE=TrthExchangeMaps_4_0_0P1 
# log file
FH_LOG_FILE=testFileSubscription.log 
# port to publish results to 
TP_PORT=24143 


## command
./rfavelocity \
--deltacontrol-license=../../../delta-bin/config/.delta.lic \
--deltacontrol-primary-port=0 \
--kdbpublisher-build-schema=false \
--kdbpublisher-host=localhost \
--kdbpublisher-max-timeout-interval=10 \
--kdbpublisher-port=${TP_PORT} \
--kdbpublisher-schema-filename=../schema/${FH_SCHEMA_FILE} \
--kdbpublisher-send-schema-cmd=false \
--kdbpublisher-timeout-interval-step=1 \
--kdbpublisher-type=tcp \
--linehandler-check-publisher=false \
--linehandler-connect-end=00:00:00 \
--linehandler-connect-start=00:00:00 \
--linehandler-line-check-interval=0 \
--logging-debug=false \
--logging-enable-date=true \
--logging-filename=${FH_LOG_FILE} \
--logging-roll-size=200000000 \
--logging-thread-safe=true \
--rfa-asset-class=${FH_ASSET_CLASS} \
--rfa-config-filename=../config/ExampleRFA.cfg \
--rfa-consumer-name=FDConsumer \
--rfa-dict-path=../../../delta-bin/software/${FH_EXCHANGE_MAP_PACKAGE}/RDMFieldDict/RDMFieldDictionary \
--rfa-dispatcher-wait-time=100 \
--rfa-enumdef-filename=../../../delta-bin/software/${FH_EXCHANGE_MAP_PACKAGE}/ExchangeMaps/latest/enumtype.def \
--rfa-event-queue-name=FDEventQueue \
--rfa-exchangemap-filename=../../../delta-bin/software/${FH_EXCHANGE_MAP_PACKAGE}/ExchangeMaps/latest/exchgmap.txt \
--rfa-fieldmap-filename=../config/${FH_FIELD_MAP} \
--rfa-is-mbp-feed=false \
--rfa-service-name=hEDD \
--rfa-session-name=SessionRSSL \
--rfa-stdout-debug=false \
--rfa-subscribe-chain-count=100 \
--rfa-subscription-batch-size=1000 \
--rfa-user-name=instance4 \
--rfasubscription-market-price=${FH_SUBSCRIPTION_LIST} \
--timeval-feed-timezone=UTC \
--timeval-publish-timezone=UTC 
