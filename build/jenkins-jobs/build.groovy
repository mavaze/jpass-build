@Library('jenkins-libs@8303325b6f0b2c0c8a8d6c610a044897c48871e0')
import groovy.transform.Field

// Have to keep the templates values due to jenkins builds..
@Field String service = 'dummy-service'
@Field String team = 'dummy'
@Field String MMS_NAME = service
@Field String ART_NAMESPACE = team
@Field String TEAM = team
@Field String TEAM_SLACK = 'dummy-slack'
@Field String PROJECT_NAME = service

List testConfigs = [
    [
        'title'               : 'golang tests',
        'testsScriptToRun'    : './dev/go-test-coverage.sh',
        'reportsLocation'     : 'pkg',
        'reportsTypes'        : ['*.log', '*.html', '*.xml'],
        'baseRequestMemory'   : '2Gi',
        'baseRequestCpu'      : '2',
        'requestMemory'       : '8Gi',
        'requestCpu'          : '8'
    ]
]

LinkedHashMap buildParams = [
    projectName               : PROJECT_NAME,
    images                    : [],
    tests                     : testConfigs,
    apiDocParams              : null,
    team                      : TEAM,
    teamSlackChannel          : TEAM_SLACK,
    buildParallel             : true,
    testParallel              : true,
    useNewArtifactory         : true,
    artNamespace              : ART_NAMESPACE,
    markForPromotion          : false,
    closureBeforeBuild        : null,
    closureBeforeTests        : null,
    closureFinal              : null
]

sharedMmsSteps.mmsCommonBuildFlow(buildParams)
