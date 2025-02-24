mkdir agent
cd agent
wget https://vstsagentpackage.azureedge.net/agent/4.248.0/vsts-agent-linux-x64-4.248.0.tar.gz
tar xvzf vsts-agent-linux-x64-4.248.0.tar.gz

./config.sh \
--acceptteeeula \
--agent $HOSTNAME \
--url https://dev.azure.com/<ORGANIZATION_NAME>/ \
--work _work \
--projectname '<PROJECT_NAME>' \
--auth PAT --token <PERSONAL_ACCESS_TOKEN> \
--pool '<AGENT_POOL_NAME>'