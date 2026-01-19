@Library('jenkins-lib') _

/**
 * Terraform Live Envs Pipeline
 *
 * Two modes of operation:
 * 1. Default (on commit): Upload CloudFormation file to S3 when changed
 * 2. MPC Bootstrap (webhook): Create new MPC environment when MPC_CONFIG_YAML is provided
 */

// Parameters for MPC Bootstrap (only used when triggered via webhook)
properties([
    parameters([
        text(
            name: 'MPC_CONFIG_YAML',
            defaultValue: '',
            description: 'MPC configuration in YAML format (triggers MPC bootstrap when provided)'
        ),
        booleanParam(
            name: 'DRY_RUN',
            defaultValue: false,
            description: 'MPC Bootstrap: Preview changes without creating branch/PR'
        ),
        booleanParam(
            name: 'SKIP_PR',
            defaultValue: false,
            description: 'MPC Bootstrap: Skip PR creation (only commit to branch)'
        )
    ])
])

// Constants
STATIC_ASSETS_BUCKET = "preset-io-static-assets"
CLOUDFORMATION_FILE = "aws/preset-iam.yaml"

podTemplate(
    imagePullSecrets: ['preset-pull'],
    nodeUsageMode: 'NORMAL',
    containers: [
        containerTemplate(
            alwaysPullImage: true,
            name: 'ci',
            image: 'preset/ci:2025-10-08',
            ttyEnabled: true,
            command: 'cat',
            resourceRequestCpu: '500m',
            resourceLimitCpu: '1000m',
            resourceRequestMemory: '500Mi',
            resourceLimitMemory: '1000Mi',
        ),
    ]
) {
    node(POD_LABEL) {
        def repo = checkout scm
        def gitCommitSha = repo.GIT_COMMIT
        def branchName = presetGH.getBranchName()

        // Determine which pipeline to run based on parameters
        def isMpcBootstrap = params.MPC_CONFIG_YAML?.trim()

        if (isMpcBootstrap) {
            // ============================================
            // MPC BOOTSTRAP PIPELINE (webhook triggered)
            // ============================================
            runMpcBootstrap()
        } else {
            // ============================================
            // CLOUDFORMATION UPLOAD PIPELINE (default)
            // ============================================
            runCloudFormationUpload(branchName)
        }
    }
}

/**
 * MPC Bootstrap Pipeline
 * Triggered via webhook with MPC_CONFIG_YAML parameter
 */
def runMpcBootstrap() {
    stage('Parse YAML Config') {
        container('ci') {
            // Write YAML to temp file (outside git directory) and parse
            writeFile file: '/tmp/mpc-config.yaml', text: params.MPC_CONFIG_YAML
            def config = readYaml file: '/tmp/mpc-config.yaml'

            // Validate required fields
            def requiredFields = [
                'mpc_name',
                'account_id',
                'region',
                'cidr',
                'external_id',
                'datadog_external_id'
            ]

            def missingFields = requiredFields.findAll { !config[it] }
            if (missingFields) {
                error "Missing required fields: ${missingFields.join(', ')}"
            }

            // Validate account_id format (12 digits)
            def accountId = config.account_id.toString()
            if (!accountId.matches(/^\d{12}$/)) {
                error "Invalid account_id format: must be 12 digits"
            }

            // Validate CIDR format
            if (!config.cidr.matches(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}$/)) {
                error "Invalid CIDR format: ${config.cidr}"
            }

            // Store in environment variables
            env.MPC_NAME = config.mpc_name
            env.ACCOUNT_ID = accountId
            env.REGION = config.region
            env.CIDR = config.cidr
            env.EXTERNAL_ID = config.external_id
            env.DATADOG_EXTERNAL_ID = config.datadog_external_id
            env.MPC_ENVIRONMENT = config.environment ?: 'production'

            // Set build description
            currentBuild.displayName = "#${BUILD_NUMBER} - MPC: ${env.MPC_NAME}"
            currentBuild.description = "MPC Bootstrap | ${env.MPC_NAME} | ${env.REGION} | ${env.MPC_ENVIRONMENT}"

            echo """
========================================
MPC Bootstrap Configuration
========================================
MPC Name:     ${env.MPC_NAME}
Account ID:   ${env.ACCOUNT_ID}
Region:       ${env.REGION}
CIDR:         ${env.CIDR}
Environment:  ${env.MPC_ENVIRONMENT}
Dry Run:      ${params.DRY_RUN}
Skip PR:      ${params.SKIP_PR}
========================================
"""
        }
    }

    stage('Setup Python Environment') {
        container('ci') {
            sh '''
                cd ${WORKSPACE}
                cd mpc
                python3 -m venv venv
                . venv/bin/activate
                pip install --upgrade pip
                pip install -e .
            '''
        }
    }

    stage('Run MPC Bootstrap') {
        container('ci') {
            withCredentials([
                usernamePassword(
                    credentialsId: 'gh-preset-machine',
                    usernameVariable: 'GH_USER',
                    passwordVariable: 'GH_TOKEN'
                )
            ]) {
                script {
                    def flags = ['--skip-branch-switch']
                    if (params.DRY_RUN) {
                        flags.add('--dry-run')
                    }
                    if (params.SKIP_PR) {
                        flags.add('--skip-pr')
                    }
                    def extraFlags = flags.join(' ')

                    // Capture output to extract PR URL
                    def output = sh(
                        script: """
                            # Mark all directories as safe (Git CVE-2022-24765)
                            # Write directly to gitconfig to avoid chicken-and-egg problem
                            mkdir -p ~/.gitconfig.d
                            echo '[safe]' > ~/.gitconfig.d/safe.conf
                            echo '    directory = *' >> ~/.gitconfig.d/safe.conf
                            git config --global --includes include.path ~/.gitconfig.d/safe.conf 2>/dev/null || \
                                echo -e '[safe]\\n    directory = *' >> ~/.gitconfig

                            cd \${WORKSPACE}

                            # Configure git for commits
                            git config user.email "jenkins@preset.io"
                            git config user.name "Jenkins CI"

                            # Activate venv and run bootstrap-mpc
                            # Note: GH_TOKEN and GH_USER env vars are used by git_ops.py for authentication
                            . mpc/venv/bin/activate

                            bootstrap-mpc \\
                                --account-id '${env.ACCOUNT_ID}' \\
                                --mpc-name '${env.MPC_NAME}' \\
                                --region '${env.REGION}' \\
                                --cidr '${env.CIDR}' \\
                                --external-id '${env.EXTERNAL_ID}' \\
                                --datadog-external-id '${env.DATADOG_EXTERNAL_ID}' \\
                                --environment '${env.MPC_ENVIRONMENT}' \\
                                ${extraFlags}
                        """,
                        returnStdout: true
                    )
                    echo output

                    // Extract PR URL from output
                    def prUrlMatch = output =~ /Pull request created: (https:\/\/github\.com\/[^\s]+)/
                    if (prUrlMatch) {
                        env.PR_URL = prUrlMatch[0][1]
                        echo "Captured PR URL: ${env.PR_URL}"
                    }
                }
            }
        }
    }

    // Create Shortcut tickets if PR was created successfully
    if (env.PR_URL && !params.DRY_RUN && !params.SKIP_PR) {
        stage('Create Shortcut Tickets') {
            container('ci') {
                withCredentials([
                    string(credentialsId: 'ch-access-token', variable: 'SHORTCUT_TOKEN')
                ]) {
                    script {
                        // Shortcut IDs for Platform/Devops team
                        def groupId = '67ad4529-6cca-45f8-a516-42a2bad75f93'  // Platform/Devops

                        // Look up workflow state ID dynamically
                        def workflowsResponse = sh(
                            script: '''
                                curl -s -H "Shortcut-Token: $SHORTCUT_TOKEN" \
                                    "https://api.app.shortcut.com/api/v3/workflows"
                            ''',
                            returnStdout: true
                        )
                        def workflows = readJSON text: workflowsResponse
                        def engineeringWorkflow = workflows.find { it.name == 'Engineering' }
                        def backlogState = engineeringWorkflow?.states?.find { it.name == 'Backlog' }
                        def workflowStateId = backlogState?.id

                        if (!workflowStateId) {
                            error "Could not find 'Backlog' state in 'Engineering' workflow"
                        }
                        echo "Found workflow state ID: ${workflowStateId}"

                        // Create Epic
                        def epicName = "MPC Bootstrap: ${env.MPC_NAME} - ${env.REGION}"
                        def epicDescription = """
## MPC Bootstrap Details

| Field | Value |
|-------|-------|
| **MPC Name** | ${env.MPC_NAME} |
| **Account ID** | ${env.ACCOUNT_ID} |
| **Region** | ${env.REGION} |
| **CIDR** | ${env.CIDR} |
| **Environment** | ${env.MPC_ENVIRONMENT} |
| **PR URL** | ${env.PR_URL} |
| **Jenkins Build** | ${BUILD_URL} |

## Tasks
- [ ] Review and approve PR
- [ ] Apply Terraform changes via Atlantis
- [ ] Verify infrastructure deployment
- [ ] Update customer documentation
"""

                        def epicPayload = groovy.json.JsonOutput.toJson([
                            name: epicName,
                            description: epicDescription,
                            group_id: groupId
                        ])

                        // Write payload to workspace temp file
                        def epicPayloadFile = "${env.WORKSPACE}/epic-payload.json"
                        writeFile file: epicPayloadFile, text: epicPayload
                        echo "Epic Payload written to: ${epicPayloadFile}"

                        def epicResponse = sh(
                            script: """
                                curl -s -X POST "https://api.app.shortcut.com/api/v3/epics" \
                                    -H "Content-Type: application/json" \
                                    -H "Shortcut-Token: \$SHORTCUT_TOKEN" \
                                    --data-binary @${epicPayloadFile}
                            """,
                            returnStdout: true
                        )

                        echo "Epic API Response: ${epicResponse}"
                        def epicJson = readJSON text: epicResponse

                        if (epicJson.error) {
                            error "Failed to create Epic: ${epicJson.message}"
                        }

                        def epicId = epicJson.id
                        def epicUrl = epicJson.app_url
                        echo "Created Epic: ${epicUrl}"

                        // Create Story for applying the PR
                        def storyName = "[MPC] - ${env.MPC_NAME} Bootstrap PR for ${env.MPC_NAME}"
                        def storyDescription = """## Task
Review and apply the MPC bootstrap PR via Atlantis.

## PR Details
- **PR URL**: ${env.PR_URL}
- **MPC Name**: ${env.MPC_NAME}
- **Region**: ${env.REGION}
- **Environment**: ${env.MPC_ENVIRONMENT}

## Steps
1. Review the PR changes
2. Approve the PR
3. Atlantis will automatically run 'terraform plan'
4. Comment 'atlantis apply' to apply changes
5. Verify infrastructure is deployed correctly

## Links
- [Pull Request](${env.PR_URL})
- [Jenkins Build](${BUILD_URL})
"""

                        def storyPayload = groovy.json.JsonOutput.toJson([
                            name: storyName,
                            description: storyDescription,
                            story_type: 'chore',
                            epic_id: epicId,
                            group_id: groupId,
                            workflow_state_id: workflowStateId,
                            estimate: 5
                        ])

                        // Write payload to workspace temp file
                        def storyPayloadFile = "${env.WORKSPACE}/story-payload.json"
                        writeFile file: storyPayloadFile, text: storyPayload
                        echo "Story Payload written to: ${storyPayloadFile}"

                        def storyResponse = sh(
                            script: """
                                curl -s -X POST "https://api.app.shortcut.com/api/v3/stories" \
                                    -H "Content-Type: application/json" \
                                    -H "Shortcut-Token: \$SHORTCUT_TOKEN" \
                                    --data-binary @${storyPayloadFile}
                            """,
                            returnStdout: true
                        )

                        echo "Story API Response: ${storyResponse}"
                        def storyJson = readJSON text: storyResponse

                        if (storyJson.error) {
                            error "Failed to create Story: ${storyJson.message}"
                        }

                        def storyUrl = storyJson.app_url
                        echo "Created Story: ${storyUrl}"

                        // Store URLs for reference
                        env.SHORTCUT_EPIC_URL = epicUrl
                        env.SHORTCUT_STORY_URL = storyUrl

                        echo """
========================================
Shortcut Tickets Created
========================================
Epic:  ${epicUrl}
Story: ${storyUrl}
========================================
"""
                    }
                }
            }
        }
    }
}

/**
 * CloudFormation Upload Pipeline
 * Default behavior - runs on commits to check and upload CloudFormation file
 */
def runCloudFormationUpload(branchName) {
    stage('Check CloudFormation File Changes') {
        container('ci') {
            // Always check if file exists first
            def fileExists = sh(
                script: "test -f ${CLOUDFORMATION_FILE} && echo 'true' || echo 'false'",
                returnStdout: true
            ).trim()

            if (fileExists == 'false') {
                error("CloudFormation file ${CLOUDFORMATION_FILE} does not exist!")
            }

            // Check if the CloudFormation file was changed in this commit
            // First try HEAD~1, fallback to checking if file exists in last commit
            def fileChanged = sh(
                script: """
                    if git rev-parse HEAD~1 >/dev/null 2>&1; then
                        git diff --name-only HEAD~1 HEAD | grep '${CLOUDFORMATION_FILE}' || true
                    else
                        # First commit or shallow clone - just check if file exists
                        echo '${CLOUDFORMATION_FILE}'
                    fi
                """,
                returnStdout: true
            ).trim()

            if (fileChanged) {
                echo "CloudFormation file ${CLOUDFORMATION_FILE} was changed"
                env.FILE_CHANGED = 'true'
            } else {
                echo "CloudFormation file ${CLOUDFORMATION_FILE} was not changed, skipping upload"
                env.FILE_CHANGED = 'false'
            }
        }
    }

    stage('Upload to Static Assets') {
        container('ci') {
            if (env.FILE_CHANGED == 'true' && branchName == 'master') {
                withCredentials([[
                    $class           : 'AmazonWebServicesCredentialsBinding',
                    credentialsId    : 'ci-user',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh(
                        script: "aws s3 cp ${CLOUDFORMATION_FILE} s3://${STATIC_ASSETS_BUCKET}/mpc/preset-iam.yaml --cache-control 'max-age=300'",
                        label: 'Upload CloudFormation file to S3'
                    )
                    echo "Uploaded ${CLOUDFORMATION_FILE} to s3://${STATIC_ASSETS_BUCKET}/mpc/preset-iam.yaml"
                }
           } else {
               echo "Skipping upload - either file not changed or not on master branch"
           }
        }
    }
}
