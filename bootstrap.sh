#!/bin/sh

echo " Bootstrap script started.. "
echo " Updating packages.. "

sudo apt-get update

Install_services()
{

	cd ~
	
	echo " Installing Oracle Java 8 "
	
	#sudo apt-add-repository ppa:webupd8team/java
	#sudo apt-get update
	#sudo apt-get install oracle-java8-installer -y

	echo " Oracle Java 8 installed successfully "
	
	echo " Downlooading mongodb binary "
	
	echo "Remoiving any old versions"
	
	sudo rm -rf /var/mongodb
	sudo rm -rf /var/solr
	
	wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu1604-3.4.3.tgz
	tar -xvf mongodb-linux-x86_64-ubuntu1604-3.4.3.tgz 
	mv mongodb-linux-x86_64-ubuntu1604-3.4.3 mongodb
	sudo mv mongodb /var/

	echo " Mongodb binary configured successfully "
	
	echo " Downlooading solr binary "
	
	wget http://www-eu.apache.org/dist/lucene/solr/6.5.0/solr-6.5.0.tgz
	tar -xvf solr-6.5.0.tgz 
	mv solr-6.5.0 solr
	sudo mv solr /var/

	echo " Solr binary configured successfully "
	
	echo " Installing mongo-connector "
	
	sudo apt-get install python-pip -y
	pip install --user mongo-connector[solr]

	echo " mongo-connector installed successfully "
	
	echo " Solr creating core for opportunity "
	
	Start_solr
	
	/var/solr/bin/solr create -c opportunity

	echo " Solr opportunity core created successfully "
	
	echo " Copying schema files for opportunity core "
	
	# copy solr config files
	sudo cp -r /vagrant/solrconfig.xml /var/solr/server/solr/opportunity/conf/
	sudo cp -r /vagrant/schema.xml /var/solr/server/solr/opportunity/conf/

	echo " Opportunity core schema copied successfully  "
	
	echo " Copying mongo config  "
	sudo mkdir /var/mongodb/data
	sudo mkdir /var/mongodb/data/db
	
	# copy mongo config files
	cp /vagrant/mongo.conf /var/mongodb/  
	

	echo " Mongo configured successfully  "
	
	Start_mongodb
	Mongodb_init_replicaset
	
	echo " Copying opportunity data into mongodb  "
	
	#import opportunity json into mongodb
	/var/mongodb/bin/mongoimport --db solr --collection opportunity --file /vagrant/opportunity.json --jsonArray

	echo " Opportunity data copied to mongodb successfully  "
	
	Start_solr
}

Start_mongodb(){
	echo " Starting mongo server  "
	#start mongo server
	sudo /var/mongodb/bin/mongod --config /var/mongodb/mongo.conf &
}

Mongodb_init_replicaset(){
	echo " Starting mongo replica instance  "
	#initiate replica set
	/var/mongodb/bin/mongo --eval "rs.initiate();"
}

Start_solr(){
	echo " Starting solr server  "
	#start solr server
	/var/solr/bin/solr stop
	/var/solr/bin/solr start

	cd ~

	#configure solr to use mongodb
	mongo-connector -v -m localhost:27017 -n solr.opportunity -t http://localhost:8983/solr/#/opportunity -d solr_doc_manager --unique-key=id --auto-commit-interval=0
}

Start_services(){  

	Start_mongodb
	Mongodb_init_replicaset
	Start_solr
	
}


echo " Checking services installation "

if [ -d /var/solr &&  /var/mongodb ] 
then
	#Things to do
	echo " Services installed going to start them.. "
	Start_services

else #if needed #also: elif [new condition] 
	# things to do
	echo " Services not installed going to install them.. "
	Install_services
fi
