#!/bin/bash -x
echo "Running Tests!"
start=$(date +%s)

VERSION=${VERSION:-local}
ROOT_DIR_PATH=/opt/service
echo "ROOT_DIR_PATH=${ROOT_DIR_PATH}"

TEST_DOCKER_NAME="go-dummies"
echo "TEST_DOCKER_NAME=${TEST_DOCKER_NAME}"

echo "logging into artifactory.eng.sentinelone.tech"
echo ${ARTIFACTORY_PASSWORD} | docker login artifactory.eng.sentinelone.tech -u ${ARTIFACTORY_USER} --password-stdin

echo "Running golang docker"
start_tests=$(date +%s)

docker run --name "${TEST_DOCKER_NAME}" -i -v $(pwd):/app \
"artifactory.eng.sentinelone.tech/docker-remote/golang:1.20.0-bullseye" << COMMANDS
    git config --global \
        url."https://${GIT_TOKEN}:x-oauth-basic@github.com/Sentinel-One".insteadOf "https://github.com/Sentinel-One"
    mkdir -p ${ROOT_DIR_PATH}
    cp -R /app/go.mod /app/pkg ${ROOT_DIR_PATH}
    cd ${ROOT_DIR_PATH}
    go mod tidy \
        && architecture=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) \
        && GOARCH=${architecture} SKIP_FLAKES=1 go test ./... -v -coverprofile=testReport.out | tee testReport.log \
        && GOARCH=${architecture} go tool cover -html=testReport.out -o testReport.html     # PASS
    GOARCH=${architecture} go install github.com/jstemmer/go-junit-report/v2@latest \       # FAIL
        && go-junit-report -set-exit-code -in testReport.log -out testReport.xml            # FAIL
COMMANDS

tests_ret_val="$?"
echo "Tests finished with return code of ${tests_ret_val}"
end_tests=$(date +%s)

echo "Moving go test reports from tests docker to: ${WORKSPACE}"
rm -rf "./pkg/${VERSION}_testReport.*"
docker cp "${TEST_DOCKER_NAME}:${ROOT_DIR_PATH}/testReport.html" "./pkg/${VERSION}_testReport.html"
docker cp "${TEST_DOCKER_NAME}:${ROOT_DIR_PATH}/testReport.log" "./pkg/${VERSION}_testReport.log"
docker cp "${TEST_DOCKER_NAME}:${ROOT_DIR_PATH}/testReport.xml" "./pkg/${VERSION}_testReport.xml"

echo "Delete tests container stopped by now"
docker rm -f "${TEST_DOCKER_NAME}"
end=$(date +%s)
echo "Tests only elapsed time is $(($end_tests-$start_tests))"
echo "Total elapsed time: $(($end-$start)) seconds"
if [ "$tests_ret_val" != "0" ]; then
    echo -e "tests exit code:" $tests_ret_val "\nFailed in tests"
    exit 1
else
    echo "SUCCESSFUL"
    exit 0
fi
