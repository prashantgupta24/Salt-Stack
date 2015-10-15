echo ""
echo "/salt/states/base/top.sls file"
cat /salt/states/base/top.sls
echo ""
echo "/salt/states/base/nginx1/init.sls file"
cat /salt/states/base/nginx1/init.sls
echo ""
echo "All Minions respond! (salt '*' test.ping)"
sudo salt '*' test.ping
