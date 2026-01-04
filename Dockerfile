FROM eclipse-temurin:21-jdk-jammy

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update && apt-get install -y \
    wget \
    git \
    build-essential \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

ENV MAVEN_HOME=/opt/maven \
    PATH=/opt/maven/bin:$PATH

# Install Maven 3.9.9
RUN curl -fsSL "https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz" \
    -o /tmp/maven.tgz && \
    mkdir -p "$MAVEN_HOME" && \
    tar -xzf /tmp/maven.tgz -C "$MAVEN_HOME" --strip-components=1 && \
    rm /tmp/maven.tgz

# Create non-root user
RUN useradd -m -s /bin/bash ta4j

# Copy local codebase into container
WORKDIR /testbed
COPY --chown=ta4j:ta4j . .

# Switch to ta4j user before building
USER ta4j

# Build the project as ta4j user
RUN mvn -B clean install \
    -Dmaven.resolver.transport=wagon \
    -Dsurefire.reportFormat=plain \
    -Dsurefire.printSummary=true

# Set working directory
WORKDIR /testbed

# Default command
CMD ["/bin/bash"]
