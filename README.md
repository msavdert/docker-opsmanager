## docker-opsmanager

1. ```cd ops-manager/```
2. ```wget https://downloads.mongodb.com/on-prem-mms/rpm/mongodb-mms-3.4.3.402-1.x86_64.rpm```
3. ```mv mongodb-mms-3.4.3.402-1.x86_64.rpm mongodb-mms.x86_64.rpm```
4. ```docker build --rm --no-cache -t melihsavdert/opsmanager:3.4.2 .```
5. ```docker network create my-mongo-cluster```
6. Let's start MongoDB Ops Manager container
```
docker run --rm \ 
  --privileged \
  --name opsmanager \
  --net my-mongo-cluster \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -p 8080:8080 -p 8443:8443 -p 27017:27017 \
  -d melihsavdert/opsmanager:3.4.2
```
6. ```cd ../agent/```
7. ```docker build --rm --no-cache -t melihsavdert/mongodb-agent:3.4.2 .```
8. http://<ip-address>:8080

9. Retrieve the following parameters:

- MMS_GROUP_ID
- MMS_API_KEY
- BASE_URL

![alt tag](https://cloud.githubusercontent.com/assets/5485061/6651746/4be248a8-ca53-11e4-8637-b0391302ac6c.png)

We'll need these parameters to start the mms-agent containers.

10. Let's create 3 nodes mongodb cluster
```
docker run --rm \
	--privileged \
	--name mongo1 \
	--net my-mongo-cluster \
	-p 27000:27000 \
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	-d melihsavdert/mongodb-agent:3.4.2
```
```
docker run --rm \
	--privileged \
	--name mongo2 \
	--net my-mongo-cluster \
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	-d melihsavdert/mongodb-agent:3.4.2
```
```
  docker run --rm \
	--privileged \
	--name mongo3 \
	--net my-mongo-cluster \
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	-d melihsavdert/mongodb-agent:3.4.2
```
11. docker exec -it mongo1 bash
12. Run the same things in all mongodb containers.
```
curl -OL http://opsmanager:8080/download/agent/automation/mongodb-mms-automation-agent-manager-latest.x86_64.rhel7.rpm
rpm -U mongodb-mms-automation-agent-manager-latest.x86_64.rhel7.rpm
rm -f mongodb-mms-automation-agent-manager-latest.x86_64.rhel7.rpm
mkdir -p /var/lib/mongo && chown mongod:mongod /var/lib/mongo

mmsGroupId=58d28530027439018527210c
mmsApiKey=3a29715be6cc8517def9052cf0209050
mmsBaseUrl=http://opsmanager:8080

sed -i "s/.*mmsGroupId=.*/mmsGroupId=$mmsGroupId/g;s/.*mmsApiKey=.*/mmsApiKey=$mmsApiKey/g;s#.*mmsBaseUrl=.*#mmsBaseUrl=$mmsBaseUrl#g"  /etc/mongodb-mms/automation-agent.config

systemctl restart mongodb-mms-automation-agent.service
```
Once you have started the appropriate number of containers, return to the Ops Manager and click on the VERIFY AGENT button.

If everything is ok you'll be able to continue your deployment.
