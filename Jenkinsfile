#!groovy

node('Windows_Slave') {
    def branchName
    def lastID
    def latestID
    def deploymentHistoryBranchName = 'deployment'
    def TEST_LEVEL = 'RunLocalTests'    
    def toolbelt = tool 'salesforce'
    def groovy = tool 'groovy-3.0.4'
    def commitFileName = "${env.JOB_NAME}.txt"
    def commitFilePath = commitFileName.replaceAll('/','\\\\')

    script
    {
        if (env.JOB_NAME.contains('Crowley-Salesforce/Crowley-Salesforce-QA')) {
            withCredentials([string(credentialsId: 'CROWLEY_SF_USERNAME_QA', variable: 'SF_USERNAME'),string(credentialsId: 'CROWLEY_SF_CONSUMER_KEY_QA', variable: 'SF_CONSUMER_KEY'),string(credentialsId: 'CROWLEY_SF_SERVER_KEY_CREDENTIALS_ID', variable: 'SERVER_KEY_CREDENTIALS_ID')])
            {
                user_name = "${SF_USERNAME}"
                consumer_key = "${SF_CONSUMER_KEY}"
                server_key_id = "CROWLEY_SF_SERVER_KEY_CREDENTIALS_ID"
                instance_url = "https://test.salesforce.com"
                audience_url = "https://test.salesforce.com"
            }
        }
        else if (env.JOB_NAME.contains('Crowley-Salesforce/Crowley-Salesforce-UAT')) {
            withCredentials([string(credentialsId: 'CROWLEY_SF_USERNAME_UAT', variable: 'SF_USERNAME'),string(credentialsId: 'CROWLEY_SF_CONSUMER_KEY_UAT', variable: 'SF_CONSUMER_KEY'),string(credentialsId: 'CROWLEY_SF_SERVER_KEY_CREDENTIALS_ID', variable: 'SERVER_KEY_CREDENTIALS_ID')])
            {
                user_name = "${SF_USERNAME}"
                consumer_key = "${SF_CONSUMER_KEY}"
                server_key_id = "CROWLEY_SF_SERVER_KEY_CREDENTIALS_ID"
                instance_url = "https://test.salesforce.com"
                audience_url = "https://test.salesforce.com"
            }
        }       
        else if (env.JOB_NAME.contains('Crowley-Salesforce/Crowley-Salesforce-Production')) {
            withCredentials([string(credentialsId: 'CROWLEY_SF_USERNAME_PROD', variable: 'SF_USERNAME'),string(credentialsId: 'CROWLEY_SF_CONSUMER_KEY_PROD', variable: 'SF_CONSUMER_KEY'),string(credentialsId: 'CROWLEY_SF_SERVER_KEY_CREDENTIALS_ID', variable: 'SERVER_KEY_CREDENTIALS_ID')])
            {
                user_name = "${SF_USERNAME}"
                consumer_key = "${SF_CONSUMER_KEY}"
                server_key_id = "CROWLEY_SF_SERVER_KEY_CREDENTIALS_ID"
                instance_url = "https://login.salesforce.com"
                audience_url = "https://login.salesforce.com"
            }
        }               
        else if (env.JOB_NAME.contains('Crowley-Salesforce/Crowley-Salesforce-HotFix')) {
            withCredentials([string(credentialsId: 'CROWLEY_SF_USERNAME_HOTFIX', variable: 'SF_USERNAME'),string(credentialsId: 'CROWLEY_SF_CONSUMER_KEY_HOTFIX', variable: 'SF_CONSUMER_KEY'),string(credentialsId: 'CROWLEY_SF_SERVER_KEY_CREDENTIALS_ID', variable: 'SERVER_KEY_CREDENTIALS_ID')])
            {
                user_name = "${SF_USERNAME}"
                consumer_key = "${SF_CONSUMER_KEY}"
                server_key_id = "CROWLEY_SF_SERVER_KEY_CREDENTIALS_ID"
                instance_url = "https://test.salesforce.com"
                audience_url = "https://test.salesforce.com"
            }
        }              
        else if (env.JOB_NAME.contains('Crowley-Salesforce/Crowley-Salesforce-DevOps')) {
            withCredentials([string(credentialsId: 'CROWLEY_SF_USERNAME_DEVOPS', variable: 'SF_USERNAME'),string(credentialsId: 'CROWLEY_SF_CONSUMER_KEY_DEVOPS', variable: 'SF_CONSUMER_KEY')])
            {
                user_name = "${SF_USERNAME}"
                consumer_key = "${SF_CONSUMER_KEY}"
                server_key_id = "CROWLEY_SF_SERVER_KEY_CREDENTIALS_ID"
                instance_url = "https://test.salesforce.com"
                audience_url = "https://test.salesforce.com"
            }
        }
        else if (env.JOB_NAME.contains('Crowley-Salesforce/Crowley-Salesforce-CICD')) {
            withCredentials([string(credentialsId: 'CROWLEY_SF_USERNAME_CICD', variable: 'SF_USERNAME'),string(credentialsId: 'CROWLEY_SF_CONSUMER_KEY_CICD', variable: 'SF_CONSUMER_KEY')])
            {
                user_name = "${SF_USERNAME}"
                consumer_key = "3MVG90D5vR7UtjbqV5d7pG9oIPOFhQ38DL5S4nldpHrQhUuigC2adrfix5b_Klne_9O4TZjuJnP_TUdGkIIei"
                server_key_id = "CROWLEY_SF_SERVER_KEY_CREDENTIALS_ID"
                instance_url = "https://test.salesforce.com"//"https://crowley2--cicd.my.salesforce.com"
                audience_url = "https://test.salesforce.com"
            }
        }
        else{
            user_name = "test"
            consumer_key = "test"
            server_key_id = 'test'
            instance_url = "https://test.salesforce.com"
            audience_url = "https://test.salesforce.com"
        }
        //Git credentials used for post commiting
        withCredentials([usernamePassword(credentialsId: 'infrasupport', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
            git_user_name = "${GIT_USERNAME}"
            git_password = "${GIT_PASSWORD}"
            git_repository_url = "https://${GIT_USERNAME}:${GIT_PASSWORD}@git.nagarro.com/root/CROCROSA.git"
        }
        
    } 
    
    // println commitFilePath
    // println consumer_key
    // println server_key_id
    // println user_name
    // println instance_url
    // println audience_url
    // println commitFileName
    // println git_user_name
    // println git_password
    //
    // -------------------------------------------------------------------------
    // Check out code from source control GIT
    // -------------------------------------------------------------------------

    stage('Clean Workspace') {
        try {
            deleteDir()
        }
        catch (Exception e) {
            println('Unable to Clean WorkSpace.')
        }
    }

    stage('Checkout Git Source') {
        checkout scm
        
        def branchOriginName = bat (label: 'Branch name', script: '@git name-rev --name-only HEAD', returnStdout: true).trim() as String   
        branchName = branchOriginName.replaceAll('remotes/origin/','').split('~')[0]
        println branchName
    }

    // -------------------------------------------------------------------------
    // Run all the enclosed stages with access to the Salesforce
    // JWT key credentials.
    // -------------------------------------------------------------------------

    withCredentials([file(credentialsId: "${server_key_id}", variable: 'server_key_file')]) {
        // -------------------------------------------------------------------------
        // Authenticate to Salesforce using the server key.
        // -------------------------------------------------------------------------
        //sfdx force:auth:logout --targetusername %USERNAME% -p =sfdx force:auth:logout --targetusername vidhi.saxena@nagarro.com.research -p
        stage('Authorize to Salesforce') {
            rc = command "${toolbelt}/sfdx force:auth:logout --targetusername ${user_name} -p"
            rc = command 'set SFDX_AUDIENCE_URL="' + audience_url + '"' 
            rc = command "${toolbelt}/sfdx force:auth:jwt:grant --instanceurl ${instance_url} --clientid ${consumer_key} --jwtkeyfile ${server_key_file} --username ${user_name} --setdefaultdevhubusername"
            if (rc != 0) {
                error 'Salesforce org authorization failed.'
            }
            
        }

        stage('Get Last Deployment'){
            script{
                println branchName
                bat 'git checkout ' + deploymentHistoryBranchName + ''
                
                lastID = bat(label: 'Get last commit id', returnStdout: true, script:'@powershell -command "cat DevOps\\LastDeploymentState\\' + commitFilePath + '"').trim() as String
                //def lastID = bat 'powershell -command "cat DevOps\\LastDeploymentState\\' + commitFilePath + '"'
                println lastID

                bat 'git checkout ' + branchName + ''
            }            
        }

        //Run Powershell Sript - CHANGE HERE
        stage('Delta Deployment') {
            script {
                println lastID
                bat 'powershell -command "git diff-tree --no-commit-id --name-only -r ' + lastID + ' head > list.txt"'
                bat 'python copyDeltaFiles.py'

                try {
                    bat '"' + "${groovy}/bin/groovy" + '"' + " PackageXMLGenerator.groovy delta/force-app/main/default delta/force-app/main/default/package.xml"
                    bat 'sfdx force:mdapi:deploy -d delta/force-app/main/default -w 30 --targetusername ' + user_name + ''
                    
                } catch (Exception e) {
                    //throw e
                    println("No files for Delta deployment")
                }
                
                try {                    
                    bat '"' + "${groovy}/bin/groovy" + '"' + " DestructiveXMLGenerator.groovy deltaDestruction/force-app/main/default deltaDestruction/force-app/main/default/manifest/destructiveChanges.xml"
                    bat 'sfdx force:mdapi:deploy -d deltaDestruction/force-app/main/default/manifest -w 30 --targetusername ' + user_name + ''
                   
                } catch (Exception e) {
                    println("No files for Delta destruction deployment")
                } 

                latestID = bat(label: 'Get latest commit id', returnStdout: true, script:'@git rev-parse HEAD').trim() as String
                println latestID
            }
        }

        
        stage('Set Latest Deployment'){
            script{
                println branchName
                println latestID
                bat 'git checkout ' + deploymentHistoryBranchName + ''
                bat(label: 'Set file content', returnStdout: true, script:'@powershell -command "Set-Content -Path DevOps\\LastDeploymentState\\' + commitFilePath + ' -Value ' + latestID + ' -Force "')
                // Git commit latest deployed commitid
                def latest = bat(label: 'Get latest commit id', returnStdout: true, script:'@powershell -command "cat DevOps\\LastDeploymentState\\' + commitFilePath + '"').trim() as String
                println latest
                bat 'git commit -am "Delta Deployment succeeded" '
                bat 'git push ' + git_repository_url + ' HEAD:' + deploymentHistoryBranchName + ' --force'
            }            
        }

    }
}

def command(script) {
    if (isUnix()) {
        return sh(returnStatus: true, script: script);
    } else {
        return bat(returnStatus: true, script: script);
    }
}