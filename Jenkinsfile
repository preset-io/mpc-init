@Library('jenkins-lib') _

/**
 * CloudFormation S3 Upload Pipeline
 *
 * Uploads CloudFormation file to S3 when changed on master branch
 */

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
}
