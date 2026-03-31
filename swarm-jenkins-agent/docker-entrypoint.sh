#!/bin/sh

# Запустить виртуальный дисплей напрямую (не через s6, т.к. он не PID1)
Xvfb ${DISPLAY:-:99} -screen 0 ${DISPLAY_WIDTH:-1440}x${DISPLAY_HEIGHT:-900}x24 -nolisten tcp &
sleep 1

if [ -f "/init" ]; then
  /init &
fi

sleep 1

wget -O agent.jar $DOCKER_SWARM_PLUGIN_JENKINS_AGENT_JAR_URL && \
  java -jar agent.jar \
    -jnlpUrl $DOCKER_SWARM_PLUGIN_JENKINS_AGENT_JNLP_URL \
    -secret $DOCKER_SWARM_PLUGIN_JENKINS_AGENT_SECRET \
    -noReconnect \
    -workDir /home/jenkins
