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
                      <value>http://{{ template "jenkins.fullname" . }}:{{.Values.Master.ServicePort}}{{ default "" .Values.Master.JenkinsUriPrefix }}</value>
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
        <hudson.plugins.ec2.EC2Cloud plugin="ec2@1.38">
          <name>ec2-docker-agents</name>
          <useInstanceProfileForCredentials>false</useInstanceProfileForCredentials>
          <credentialsId>aws</credentialsId>
          <privateKey>
            <privateKey>{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}</privateKey>
          </privateKey>
          <instanceCap>2147483647</instanceCap>
          <templates>
            <hudson.plugins.ec2.SlaveTemplate>
              <ami>ami-57211232</ami>
              <description>docker</description>
              <zone></zone>
              <securityGroups>docker</securityGroups>
              <remoteFS></remoteFS>
              <type>T2Micro</type>
              <ebsOptimized>false</ebsOptimized>
              <labels>docker xxx</labels>
              <mode>NORMAL</mode>
              <initScript></initScript>
              <tmpDir></tmpDir>
              <userData></userData>
              <numExecutors>1</numExecutors>
              <remoteAdmin>ubuntu</remoteAdmin>
              <jvmopts></jvmopts>
              <subnetId></subnetId>
              <idleTerminationMinutes>1</idleTerminationMinutes>
              <iamInstanceProfile></iamInstanceProfile>
              <deleteRootOnTermination>false</deleteRootOnTermination>
              <useEphemeralDevices>false</useEphemeralDevices>
              <customDeviceMapping></customDeviceMapping>
              <instanceCap>2147483647</instanceCap>
              <stopOnTerminate>false</stopOnTerminate>
              <usePrivateDnsName>false</usePrivateDnsName>
              <associatePublicIp>false</associatePublicIp>
              <useDedicatedTenancy>false</useDedicatedTenancy>
              <launchTimeout>2147483647</launchTimeout>
              <connectBySSHProcess>false</connectBySSHProcess>
              <connectUsingPublicIp>false</connectUsingPublicIp>
              <node>true</node>
            </hudson.plugins.ec2.SlaveTemplate>
          </templates>
          <region>us-east-2</region>
        </hudson.plugins.ec2.EC2Cloud>
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
      <label></label>
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
  apply_config.sh: |-
    mkdir -p /usr/share/jenkins/ref/secrets/;
    echo "false" > /usr/share/jenkins/ref/secrets/slave-to-master-security-kill-switch;
    cp -n /var/jenkins_config/config.xml /var/jenkins_home;
{{- if .Values.Master.InstallPlugins }}
    cp /var/jenkins_config/plugins.txt /var/jenkins_home;
    rm -rf /usr/share/jenkins/ref/plugins/*.lock
    /usr/local/bin/install-plugins.sh `echo $(cat /var/jenkins_home/plugins.txt)`;
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