create-project:
	@mvn archetype:generate \
		-DgroupId=com.mycompany.app \
		-DartifactId=$(name) \
		-DarchetypeArtifactId=maven-archetype-quickstart \
		-DarchetypeVersion=1.5 \
		-DinteractiveMode=false
# make create-project name=practice_1
