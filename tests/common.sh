
#!/usr/bin/env bash

function build_sketches()
{
    set +e
    local srcpath=$1
    local build_arg=$2
    local build_cmd="make ESP8266_VERSION=$build_arg "
    local makefiles=$(find $srcpath -name Makefile*)
    export ARDUINO_IDE_PATH=$arduino
    for makefile in $makefiles; do
        echo "$build_cmd -f $makefile"
        time ($build_cmd -f $makefile >build.log)
        local result=$?
        if [ $result -ne 0 ]; then
            echo "Build failed ($1)"
            echo "Build log:"
            cat build.log
            set -e
            return $result
        fi
        rm build.log
    done
    set -e
}

function install_cores()
{
    wget -O https://github.com/esp8266/Arduino/releases/download/2.3.0/esp8266-2.3.0.zip
    unzip esp8266-2.3.0.zip
    cp -R bin/package esp8266
    cd esp8266-2.3.0/tools
    python get.py
    #export PATH="$ide_path:$core_path/tools/xtensa-lx106-elf/bin:$PATH"
    git clone https://github.com/esp8266/Arduino.git esp8266.git
    cd esp8266;GIT/tools
    python get.py
}

function run_travis_ci_build()
{
    # Install ESP8266 cores 2.3.0 and git versions
    echo -e "travis_fold:start:sketch_test_env_prepare"
    cd $TRAVIS_BUILD_DIR
    install_cores
    echo -e "travis_fold:end:sketch_test_env_prepare"

    # Compile sketches
    echo -e "travis_fold:start:sketch_test"
    build_sketches $HOME/examples/esp8266
    echo -e "travis_fold:end:sketch_test"
}

set -e

if [ "$BUILD_TYPE" = "build" ]; then
    run_travis_ci_build
fi

