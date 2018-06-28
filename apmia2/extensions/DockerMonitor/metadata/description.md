Follow these steps to install the software on every node of the Swarm Setup:
1.	As a prerequisite, ensure that the Docker daemon is running on the UNIX machine on which you want to install the agent.
2.	Untar the DockerMonitor_Agent_vX.tar file to a location of your choice.
3.	Navigate to the collectoragent/bin directory and run ./CollectorAgent.sh start to deploy the following directories:
•	collectoragent/extensions/DockerMonitor
•	collectoragent/extensions/ContainerFlow
4.	Navigate to the collectoragent/extensions/DockerMonitor directory and open the bundle.properties file in a text editor. Configure the following properties:
•	docker.hostname
The name of the Docker server host. It should exactly match the $HOSTNAME environment variable of the Docker Swarm master node. This value is used to discover all associated servers. This property is required. There is no default value.
•	docker.port
The HTTPS port the Docker daemon process is bound to. This property is required. There is no default value.
5.	Download the client certificate bundle from the UCP web UI, as explained in the Docker documentation (https://docs.docker.com/datacenter/ucp/2.1/guides/user/access-ucp/cli-based-access/, and copy the ca.pem, cert.pem and key.pem files to the extensions/DockerMonitor/certificates folder.
6.	Repeat steps 3-5 on every node in a Docker Standalone or Swarm setup.

Note: The CollectorAgent script also creates a container named containerflow-agent. The Container Flow Agent starts automatically. No further configuration is needed.


