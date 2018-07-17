{{- define "override_config_map" }}

apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ template "jenkins.fullname" . }}
data:
  config.xml: |-
    <?xml version='1.0' encoding='UTF-8'?>
    <hudson>
      <disabledAdministrativeMonitors/>
      <version>{{ .Values.Master.ImageTag }}</version>
      <numExecutors>0</numExecutors>
      <mode>NORMAL</mode>
      <useSecurity>{{ .Values.Master.UseSecurity }}</useSecurity>
      <authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy">
        <denyAnonymousReadAccess>true</denyAnonymousReadAccess>
      </authorizationStrategy>
      <securityRealm class="hudson.security.LegacySecurityRealm"/>
      <disableRememberMe>false</disableRememberMe>
      <projectNamingStrategy class="jenkins.model.ProjectNamingStrategy$DefaultProjectNamingStrategy"/>
      <workspaceDir>${JENKINS_HOME}/workspace/${ITEM_FULLNAME}</workspaceDir>
      <buildsDir>${ITEM_ROOTDIR}/builds</buildsDir>
      <markupFormatter class="hudson.markup.EscapedMarkupFormatter"/>
      <jdks/>
      <viewsTabBar class="hudson.views.DefaultViewsTabBar"/>
      <myViewsTabBar class="hudson.views.DefaultMyViewsTabBar"/>
      <clouds>
        <org.csanchez.jenkins.plugins.kubernetes.KubernetesCloud plugin="kubernetes@{{ template "jenkins.kubernetes-version" . }}">
          <name>kubernetes</name>
          <templates>
{{- if .Values.Agent.Enabled }}
            <org.csanchez.jenkins.plugins.kubernetes.PodTemplate>
              <inheritFrom></inheritFrom>
              <name>default</name>
              <instanceCap>2147483647</instanceCap>
              <idleMinutes>0</idleMinutes>
              <label>{{ .Release.Name }}-{{ .Values.Agent.Component }}</label>
              <nodeSelector>
                {{- $local := dict "first" true }}
                {{- range $key, $value := .Values.Agent.NodeSelector }}
                  {{- if not $local.first }},{{- end }}
                  {{- $key }}={{ $value }}
                  {{- $_ := set $local "first" false }}
                {{- end }}</nodeSelector>
                <nodeUsageMode>NORMAL</nodeUsageMode>
              <volumes>
{{- range $index, $volume := .Values.Agent.volumes }}
                <org.csanchez.jenkins.plugins.kubernetes.volumes.{{ $volume.type }}Volume>
{{- range $key, $value := $volume }}{{- if not (eq $key "type") }}
                  <{{ $key }}>{{ $value }}</{{ $key }}>
{{- end }}{{- end }}
                </org.csanchez.jenkins.plugins.kubernetes.volumes.{{ $volume.type }}Volume>
{{- end }}
              </volumes>
              <containers>
                <org.csanchez.jenkins.plugins.kubernetes.ContainerTemplate>
                  <name>jnlp</name>
                  <image>{{ .Values.Agent.Image }}:{{ .Values.Agent.ImageTag }}</image>
{{- if .Values.Agent.Privileged }}
                  <privileged>true</privileged>
{{- else }}
                  <privileged>false</privileged>
{{- end }}
                  <alwaysPullImage>{{ .Values.Agent.AlwaysPullImage }}</alwaysPullImage>
                  <workingDir>/home/jenkins</workingDir>
                  <command></command>
                  <args>${computer.jnlpmac} ${computer.name}</args>
                  <ttyEnabled>false</ttyEnabled>
                  <resourceRequestCpu>{{.Values.Agent.Cpu}}</resourceRequestCpu>
                  <resourceRequestMemory>{{.Values.Agent.Memory}}</resourceRequestMemory>
                  <resourceLimitCpu>{{.Values.Agent.Cpu}}</resourceLimitCpu>
                  <resourceLimitMemory>{{.Values.Agent.Memory}}</resourceLimitMemory>
                  <envVars>
                    <org.csanchez.jenkins.plugins.kubernetes.ContainerEnvVar>
                      <key>JENKINS_URL</key>
                      <value>http://{{ template "jenkins.fullname" . }}.{{ .Release.Namespace }}:{{.Values.Master.ServicePort}}{{ default "" .Values.Master.JenkinsUriPrefix }}</value>
                    </org.csanchez.jenkins.plugins.kubernetes.ContainerEnvVar>
                  </envVars>
                </org.csanchez.jenkins.plugins.kubernetes.ContainerTemplate>
              </containers>
              <envVars/>
              <annotations/>
{{- if .Values.Agent.ImagePullSecret }}
              <imagePullSecrets>
                <org.csanchez.jenkins.plugins.kubernetes.PodImagePullSecret>
                  <name>{{ .Values.Agent.ImagePullSecret }}</name>
                </org.csanchez.jenkins.plugins.kubernetes.PodImagePullSecret>
              </imagePullSecrets>
{{- else }}
              <imagePullSecrets/>
{{- end }}
              <nodeProperties/>
            </org.csanchez.jenkins.plugins.kubernetes.PodTemplate>
{{- end -}}
          </templates>
          <serverUrl>https://kubernetes.default</serverUrl>
          <skipTlsVerify>false</skipTlsVerify>
          <namespace>{{ .Release.Namespace }}</namespace>
          <jenkinsUrl>http://{{ template "jenkins.fullname" . }}.{{ .Release.Namespace }}:{{.Values.Master.ServicePort}}{{ default "" .Values.Master.JenkinsUriPrefix }}</jenkinsUrl>
          <jenkinsTunnel>{{ template "jenkins.fullname" . }}-agent.{{ .Release.Namespace }}:50000</jenkinsTunnel>
          <containerCap>10</containerCap>
          <retentionTimeout>5</retentionTimeout>
          <connectTimeout>0</connectTimeout>
          <readTimeout>0</readTimeout>
        </org.csanchez.jenkins.plugins.kubernetes.KubernetesCloud>
{{- if .Values.Master.DockerAMI }}
        <hudson.plugins.ec2.EC2Cloud plugin="ec2@1.39">
          <name>ec2-docker-agents</name>
          <useInstanceProfileForCredentials>false</useInstanceProfileForCredentials>
          <credentialsId>aws</credentialsId>
          <privateKey>
            <privateKey></privateKey>
          </privateKey>
          <instanceCap>2147483647</instanceCap>
          <templates>
            <hudson.plugins.ec2.SlaveTemplate>
              <ami>{{.Values.Master.DockerAMI}}</ami>
              <description>docker</description>
              <zone></zone>
              <securityGroups>docker</securityGroups>
              <remoteFS></remoteFS>
              <type>T2Micro</type>
              <ebsOptimized>false</ebsOptimized>
              <labels>docker</labels>
              <mode>NORMAL</mode>
              <initScript></initScript>
              <tmpDir></tmpDir>
              <userData></userData>
              <numExecutors></numExecutors>
              <remoteAdmin>ubuntu</remoteAdmin>
              <jvmopts></jvmopts>
              <subnetId></subnetId>
              <idleTerminationMinutes>10</idleTerminationMinutes>
              <iamInstanceProfile></iamInstanceProfile>
              <deleteRootOnTermination>false</deleteRootOnTermination>
              <useEphemeralDevices>false</useEphemeralDevices>
              <customDeviceMapping></customDeviceMapping>
              <instanceCap>2147483647</instanceCap>
              <stopOnTerminate>false</stopOnTerminate>
              <usePrivateDnsName>false</usePrivateDnsName>
              <associatePublicIp>false</associatePublicIp>
              <useDedicatedTenancy>false</useDedicatedTenancy>
              <amiType class="hudson.plugins.ec2.UnixData">
                <rootCommandPrefix></rootCommandPrefix>
                <slaveCommandPrefix></slaveCommandPrefix>
                <sshPort>22</sshPort>
              </amiType>
              <launchTimeout>2147483647</launchTimeout>
              <connectBySSHProcess>false</connectBySSHProcess>
              <connectUsingPublicIp>false</connectUsingPublicIp>
            </hudson.plugins.ec2.SlaveTemplate>
          </templates>
          <region>us-east-2</region>
        </hudson.plugins.ec2.EC2Cloud>
{{- end }}
{{- if .Values.Master.GProject }}
        <com.google.jenkins.plugins.computeengine.ComputeEngineCloud plugin="google-compute-engine@1.0.4">
          <name>gce-docker</name>
          <instanceCap>2147483647</instanceCap>
          <projectId>{{.Values.Master.GProject}}</projectId>
          <credentialsId>{{.Values.Master.GProject}}</credentialsId>
          <configurations>
            <com.google.jenkins.plugins.computeengine.InstanceConfiguration>
              <description>Docker build instances</description>
              <namePrefix>docker</namePrefix>
              <region>https://www.googleapis.com/compute/v1/projects/{{.Values.Master.GProject}}/regions/us-east1</region>
              <zone>https://www.googleapis.com/compute/v1/projects/{{.Values.Master.GProject}}/zones/us-east1-b</zone>
              <machineType>https://www.googleapis.com/compute/v1/projects/{{.Values.Master.GProject}}/zones/us-east1-b/machineTypes/n1-standard-2</machineType>
              <numExecutorsStr>1</numExecutorsStr>
              <startupScript></startupScript>
              <preemptible>false</preemptible>
              <labels>docker ubuntu linux</labels>
              <runAsUser>jenkins</runAsUser>
              <bootDiskType>https://www.googleapis.com/compute/v1/projects/{{.Values.Master.GProject}}/zones/us-east1-b/diskTypes/pd-ssd</bootDiskType>
              <bootDiskAutoDelete>true</bootDiskAutoDelete>
              <bootDiskSourceImageName>https://www.googleapis.com/compute/v1/projects/{{.Values.Master.GProject}}/global/images/docker</bootDiskSourceImageName>
              <bootDiskSourceImageProject>{{.Values.Master.GProject}}</bootDiskSourceImageProject>
              <networkConfiguration class="com.google.jenkins.plugins.computeengine.AutofilledNetworkConfiguration">
                <network>https://www.googleapis.com/compute/v1/projects/{{.Values.Master.GProject}}/global/networks/default</network>
                <subnetwork>default</subnetwork>
              </networkConfiguration>
              <externalAddress>false</externalAddress>
              <useInternalAddress>false</useInternalAddress>
              <networkTags></networkTags>
              <serviceAccountEmail></serviceAccountEmail>
              <mode>NORMAL</mode>
              <retentionTimeMinutesStr>6</retentionTimeMinutesStr>
              <launchTimeoutSecondsStr>300</launchTimeoutSecondsStr>
              <bootDiskSizeGbStr>10</bootDiskSizeGbStr>
              <googleLabels>
                <entry>
                  <string>jenkins_cloud_id</string>
                  <string>-1723728540</string>
                </entry>
                <entry>
                  <string>jenkins_config_name</string>
                  <string>docker</string>
                </entry>
              </googleLabels>
              <numExecutors>1</numExecutors>
              <retentionTimeMinutes>6</retentionTimeMinutes>
              <launchTimeoutSeconds>300</launchTimeoutSeconds>
              <bootDiskSizeGb>10</bootDiskSizeGb>
            </com.google.jenkins.plugins.computeengine.InstanceConfiguration>
          </configurations>
        </com.google.jenkins.plugins.computeengine.ComputeEngineCloud>
{{- end }}
      </clouds>
      <quietPeriod>5</quietPeriod>
      <scmCheckoutRetryCount>0</scmCheckoutRetryCount>
      <views>
        <hudson.model.AllView>
          <owner class="hudson" reference="../../.."/>
          <name>All</name>
          <filterExecutors>false</filterExecutors>
          <filterQueue>false</filterQueue>
          <properties class="hudson.model.View$PropertyList"/>
        </hudson.model.AllView>
      </views>
      <primaryView>All</primaryView>
      <slaveAgentPort>50000</slaveAgentPort>
      <disabledAgentProtocols>
{{- range .Values.Master.DisabledAgentProtocols }}
        <string>{{ . }}</string>
{{- end }}
      </disabledAgentProtocols>
      <label></label>
{{- if .Values.Master.CSRF.DefaultCrumbIssuer.Enabled }}
      <crumbIssuer class="hudson.security.csrf.DefaultCrumbIssuer">
{{- if .Values.Master.CSRF.DefaultCrumbIssuer.ProxyCompatability }}
        <excludeClientIPFromCrumb>true</excludeClientIPFromCrumb>
{{- end }}
      </crumbIssuer>
{{- end }}
      <nodeProperties/>
      <globalNodeProperties/>
      <noUsageStatistics>true</noUsageStatistics>
    </hudson>
{{- if .Values.Master.ScriptApproval }}
  scriptapproval.xml: |-
    <?xml version='1.0' encoding='UTF-8'?>
    <scriptApproval plugin="script-security@1.27">
      <approvedScriptHashes/>
      <approvedSignatures>
{{- range $key, $val := .Values.Master.ScriptApproval }}
        <string>{{ $val }}</string>
{{- end }}
      </approvedSignatures>
      <aclApprovedSignatures/>
      <approvedClasspathEntries/>
      <pendingScripts/>
      <pendingSignatures/>
      <pendingClasspathEntries/>
    </scriptApproval>
{{- end }}
{{- if .Values.Master.DockerVM }}
  docker-build: |-
    <?xml version='1.1' encoding='UTF-8'?>
    <slave>
      <name>docker-build</name>
      <description></description>
      <remoteFS>/tmp</remoteFS>
      <numExecutors>2</numExecutors>
      <mode>NORMAL</mode>
      <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
      <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.26">
        <host>10.100.198.200</host>
        <port>22</port>
        <credentialsId>docker-build</credentialsId>
        <maxNumRetries>0</maxNumRetries>
        <retryWaitTime>0</retryWaitTime>
        <sshHostKeyVerificationStrategy class="hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy"/>
      </launcher>
      <label>docker ubuntu</label>
      <nodeProperties/>
    </slave>
{{- end }}
  jenkins.CLI.xml: |-
    <?xml version='1.1' encoding='UTF-8'?>
    <jenkins.CLI>
{{- if .Values.Master.CLI }}
      <enabled>true</enabled>
{{- else }}
      <enabled>false</enabled>
{{- end }}
    </jenkins.CLI>
  apply_config.sh: |-
    mkdir -p /usr/share/jenkins/ref/secrets/;
    echo "false" > /usr/share/jenkins/ref/secrets/slave-to-master-security-kill-switch;
    cp -n /var/jenkins_config/config.xml /var/jenkins_home;
    cp -n /var/jenkins_config/jenkins.CLI.xml /var/jenkins_home;
{{- if .Values.Master.DockerVM }}
    mkdir -p /var/jenkins_home/nodes/docker-build
    cp /var/jenkins_config/docker-build /var/jenkins_home/nodes/docker-build/config.xml;
{{- end }}
{{- if .Values.Master.GAuthFile }}
    mkdir -p /var/jenkins_home/gauth
    cp -n /var/jenkins_secrets/{{.Values.Master.GAuthFile}} /var/jenkins_home/gauth;
{{- end }}
{{- if .Values.Master.GlobalLibraries }}
    cp -n /var/jenkins_secrets/org.jenkinsci.plugins.workflow.libs.GlobalLibraries.xml /var/jenkins_home;
{{- end }}
{{- if .Values.Master.InstallPlugins }}
    # Install missing plugins
    cp /var/jenkins_config/plugins.txt /var/jenkins_home;
    rm -rf /usr/share/jenkins/ref/plugins/*.lock
    /usr/local/bin/install-plugins.sh `echo $(cat /var/jenkins_home/plugins.txt)`;
    # Copy plugins to shared volume
    cp -n /usr/share/jenkins/ref/plugins/* /var/jenkins_plugins;
{{- end }}
{{- if .Values.Master.ScriptApproval }}
    cp -n /var/jenkins_config/scriptapproval.xml /var/jenkins_home/scriptApproval.xml;
{{- end }}
{{- if .Values.Master.InitScripts }}
    mkdir -p /var/jenkins_home/init.groovy.d/;
    cp -n /var/jenkins_config/*.groovy /var/jenkins_home/init.groovy.d/
{{- end }}
{{- if .Values.Master.CredentialsXmlSecret }}
    cp -n /var/jenkins_credentials/credentials.xml /var/jenkins_home;
{{- end }}
{{- if .Values.Master.SecretsFilesSecret }}
    cp -n /var/jenkins_secrets/* /usr/share/jenkins/ref/secrets;
{{- end }}
{{- if .Values.Master.Jobs }}
    for job in $(ls /var/jenkins_jobs); do
      mkdir -p /var/jenkins_home/jobs/$job
      cp -n /var/jenkins_jobs/$job /var/jenkins_home/jobs/$job/config.xml
    done
{{- end }}
{{- range $key, $val := .Values.Master.InitScripts }}
  init{{ $key }}.groovy: |-
{{ $val | indent 4 }}
{{- end }}
  plugins.txt: |-
{{- if .Values.Master.InstallPlugins }}
{{- range $index, $val := .Values.Master.InstallPlugins }}
{{ $val | indent 4 }}
{{- end }}
{{- end }}
{{- end -}}
