FROM eclipse-temurin:21-jdk-noble

LABEL org.opencontainers.image.source="https://github.com/namila007/moneysync"
LABEL org.opencontainers.image.description="MoneySync CI image with Flutter, Android SDK, and NDK"

ARG FLUTTER_VERSION=3.44.6
ARG NDK_VERSION=30.0.15729638
ARG ANDROID_SDK_VERSION=37

ENV ANDROID_HOME=/opt/android-sdk
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${PATH}:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools"

RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
        curl \
        git \
        unzip \
        zip \
        ripgrep \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    cd ${ANDROID_HOME}/cmdline-tools && \
    curl -fsSL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o cmdline-tools.zip && \
    unzip -q cmdline-tools.zip && \
    mv cmdline-tools latest && \
    rm cmdline-tools.zip

RUN yes | sdkmanager --licenses > /dev/null && \
    sdkmanager --install \
        "platform-tools" \
        "platforms;android-${ANDROID_SDK_VERSION}" \
        "build-tools;35.0.0" \
        "ndk;${NDK_VERSION}"

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME} && \
    flutter precache --android && \
    flutter doctor --android-licenses > /dev/null && \
    chown -R root:root ${FLUTTER_HOME}

WORKDIR /workspace
