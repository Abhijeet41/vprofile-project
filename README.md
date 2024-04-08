# Prerequisites
###
- JDK 11
- Maven 3 or later
- MySQL 5.6 or later

# Technologies 
- Spring MVC
- Spring Security
- Spring Data JPA
- Maven
- JSP
- MySQL
# Database
Here,we used Mysql DB 
MSQL DB Installation Steps for Linux ubuntu 14.04:
- $ sudo apt-get update
- $ sudo apt-get install mysql-server

Then look for the file :
- /src/main/resources/accountsdb
- accountsdb.sql file is a mysql dump file.we have to import this dump to mysql db server
- > mysql -u <user_name> -p accounts < accountsdb.sql



image: eclipse-temurin:17-jdk-jammy

stages:
  - build
  - test
  - deploy

variables:

  # ANDROID_COMPILE_SDK is the version of Android you're compiling with.
  # It should match compileSdkVersion.
  ANDROID_COMPILE_SDK: "33"

  # ANDROID_BUILD_TOOLS is the version of the Android build tools you are using.
  # It should match buildToolsVersion.
  ANDROID_BUILD_TOOLS: "33.0.2"

  # It's what version of the command line tools we're going to download from the official site.
  # Official Site-> https://developer.android.com/studio/index.html
  # There, look down below at the cli tools only, sdk tools package is of format:
  #        commandlinetools-os_type-ANDROID_SDK_TOOLS_latest.zip
  # when the script was last modified for latest compileSdkVersion, it was which is written down below
  ANDROID_SDK_TOOLS: "9477386"

# Packages installation before running script
before_script:
  - apt-get --quiet update --yes
  - apt-get --quiet install --yes wget unzip
  - export ANDROID_HOME="${PWD}/android-sdk-root"
  - install -d $ANDROID_HOME
  - wget --no-verbose --output-document=$ANDROID_HOME/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip
  - unzip -q -d "$ANDROID_HOME/cmdline-tools" "$ANDROID_HOME/cmdline-tools.zip"
  - mv -T "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/tools"
  - export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/cmdline-tools/tools/bin

  - sdkmanager --version

  # use yes to accept all licenses
  - yes | sdkmanager --licenses > /dev/null || true
  - sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}"
  - sdkmanager "platform-tools"
  - sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}"

  # Not necessary, but just for surity
  - chmod +x ./gradlew

build:
  stage: build
  script:
    - ./gradlew assemble
  artifacts:
    paths:
      - "${buildDir}/outputs/aar/toasty-release.aar"  

deploy:
  stage: deploy
  script:
    - echo "Deploying to GitLab Package Registry..."
    - ./gradlew publish  
  artifacts:
    paths:
      - "${buildDir}/outputs/aar/toasty-release.aar"
  only:
    - master
