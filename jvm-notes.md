# Jacoco
```bash
-javaagent:/home/john/dev/git/InformaCast/org.jacoco.agent-0.8.4-runtime.jar=destfile=test/reports/jacoco.exec,includes=com.berbee.*"

http://repo1.maven.org/maven2/org/jacoco/org.jacoco.agent/0.8.4/org.jacoco.agent-0.8.4-runtime.jar
http://repo1.maven.org/maven2/org/jacoco/org.jacoco.cli/0.8.4/org.jacoco.cli-0.8.4-nodeps.jar
java -jar org.jacoco.cli-0.8.4-nodeps.jar report test/reports/jacoco.exec --classfiles web/WEB-INF/classes --classfiles web/WEB-INF/lib/Plaintext.jar --html /tmp --name skunkworks
java -jar org.jacoco.cli-0.8.4-nodeps.jar execinfo test/reports/jacoco.exec
```
