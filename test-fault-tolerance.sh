#!/bin/bash

UI_IP="128.119.243.168"
CATALOG_IP="128.119.243.175"
ORDER_IP="128.119.243.175"

chmod +x *.sh 

if [ ! -f bin/test/TestRunner.class ]; then
    ./compile.sh
fi

# set classpath
CP=$(find lib/ -iname "*.jar" -exec readlink -f {} \; | tr '\n' ':')

echo "Crashing one of the catalog-server replicas.."
./crash-catalog-server.sh

echo "Crashing one of the order-server replicas.."
./crash-order-server.sh

echo -e "Clearing cached responses from UIServer..\n"
./invalidate-cache.sh

cd bin/

# run tests!

echo "Checking search/lookup/buy endpoints are still up and running.."
# test-case #1: thorough sanity tests on /search and /lookup endpoints
java -ea -cp $CP:. test.TestRunner $CATALOG_IP $UI_IP 6

# test-case #2: thorough sanity tests on /multibuy and /update endpoints
java -ea -cp $CP:. test.TestRunner $CATALOG_IP $UI_IP $ORDER_IP 7

cd ../

echo "Restarting the stopped catalog-server replica.."
./recover-catalog-server.sh

sleep 2

echo "Restarting the stopped order-server replica.."
./recover-order-server.sh

echo -e "Waiting for some time to ensure that restarted replicas are added to the load-balancers..\n"
sleep 20

echo -e "Clearing cached responses from UIServer again..\n"
./invalidate-cache.sh

cd bin/

echo "Checking search/lookup/buy are redirected to the restarted replica.."
# test-case #1: thorough sanity tests on /search and /lookup endpoints
java -ea -cp $CP:. test.TestRunner $CATALOG_IP $UI_IP 8

# test-case #2: thorough sanity tests on /multibuy and /update endpoints
java -ea -cp $CP:. test.TestRunner $CATALOG_IP $UI_IP $ORDER_IP 9
