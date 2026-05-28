FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src

COPY . .

RUN dotnet restore ./src/TopRobbers.Server/TopRobbers.Server.csproj

RUN dotnet publish ./src/TopRobbers.Server/TopRobbers.Server.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/runtime:10.0 AS runtime

ARG OPENMP_SERVER_URL

WORKDIR /opt/top-robbers/server

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        xz-utils \
        unzip \
        file \
        openssl \
        libstdc++6 \
        libatomic1 \
    && rm -rf /var/lib/apt/lists/*

RUN test -n "$OPENMP_SERVER_URL"

RUN mkdir -p /tmp/openmp \
    && curl -fsSL "$OPENMP_SERVER_URL" -o /tmp/openmp-server \
    && FILE_TYPE="$(file -b /tmp/openmp-server)" \
    && if echo "$FILE_TYPE" | grep -qi "gzip compressed"; then \
        tar -xzf /tmp/openmp-server -C /tmp/openmp; \
    elif echo "$FILE_TYPE" | grep -qi "XZ compressed"; then \
        tar -xJf /tmp/openmp-server -C /tmp/openmp; \
    elif echo "$FILE_TYPE" | grep -qi "Zip archive"; then \
        unzip -q /tmp/openmp-server -d /tmp/openmp; \
    else \
        echo "Unsupported open.mp archive type: $FILE_TYPE" && exit 1; \
    fi \
    && SERVER_DIR="$(find /tmp/openmp -type f -name 'omp-server' -printf '%h\n' | head -n 1)" \
    && test -n "$SERVER_DIR" \
    && cp -a "$SERVER_DIR"/. /opt/top-robbers/server/ \
    && chmod +x /opt/top-robbers/server/omp-server \
    && rm -rf /tmp/openmp /tmp/openmp-server

RUN mkdir -p /opt/top-robbers/server/gamemodes \
    && mkdir -p /opt/top-robbers/server/logs \
    && mkdir -p /opt/top-robbers/server/data

#COPY runtime/linux/ /opt/top-robbers/server/

COPY --from=build /app/publish/ /opt/top-robbers/server/gamemodes/

EXPOSE 7777/udp

ENTRYPOINT ["./omp-server"]