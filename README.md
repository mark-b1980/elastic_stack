# Elastic Stack Docker Compose

- [Elastic Stack Docker Compose](#elastic-stack-docker-compose)
  - [1. What is the Elastic Stack](#1-what-is-the-elastic-stack)
    - [Components](#components)
  - [2. Starting / Stopping](#2-starting--stopping)
    - [Debugging issues](#debugging-issues)
  - [3. Setting up additional ports for log inguestion](#3-setting-up-additional-ports-for-log-inguestion)
  - [4. Setting up a integration](#4-setting-up-a-integration)
    - [Settings for pfSense and Windows Integration](#settings-for-pfsense-and-windows-integration)
  - [5. Setting up an Agent](#5-setting-up-an-agent)


## 1. What is the Elastic Stack

The Elastic Stack, often referred to by its original acronym ELK (*Elasticsearch, Logstash, Kibana*), is a powerful, open-source set of tools designed to help users take data from any source, in any format, and search, analyze, and visualize it in real-time. 

### Components

The Elastic Stack operates as a coordinated pipeline to move data from where it's created to where it can be analyzed. 

The main components are:

**Beats (shippers / agents)**

Lightweight, single-purpose data forwarders installed on source systems (servers, containers, applications) to collect various types of data (e.g., logs, metrics, network traffic). They feed raw data directly to Logstash or Elasticsearch.

**Logstash (ingestion / processing)** 

A server-side data processing pipeline that ingests data from various sources (like Beats, syslog, APIs), transforms and enriches it (e.g., parsing, renaming fields, geo-mapping), and then sends it to the central store.	It receives data from Beats and outputs the processed data to Elasticsearch.

**Elasticsearch (central data store / search engine)**

It is the heart of the stack, storing all the data and providing the capabilities for powerful, real-time searching, indexing, and aggregation.	It receives processed data from Logstash and serves data queries to Kibana.

**Kibana (user interface / visualization)**

The web interface that allows users to query, analyze, and visualize the data (e.g., dashboards, graphs, maps) by sending search and aggregation requests to Elasticsearch and displays the results to the end-user.

In summary, Beats collect the data, Logstash cleans and transforms it, Elasticsearch stores and searches it, and Kibana present the search results and visualizes them.

## 2. Starting / Stopping

**Starting as deemon**

```bash
docker composer up -d
```

Docker will restart the containers after a reboot when running as deamon. 

Remove the `-d` flag, to run a single test and hit `Ctrl`+`C` to stop the containers when done.

**Stopping**

```bash
docker compose down
```

**Reloading a single container**

To reload only one container use `docker compose restart <CONTAINERNAME>` - e.g.:

```bash
docker compose restart logstash01
```

### Debugging issues

If you try to debug a Logstash input, ajdust the `logstash.conf` to show verbose output for incomming messages by uncommenting this lines in the `output` section:

```json
    ...
    # Debug Output: Print events to console
    stdout { codec => rubydebug }
```

To see what issue cause a container to crash or behave unexpected run `docker logs <CONTAINERNAME>` - e.g.:

```bash
docker logs elastic_stack-logstash01-1
```

Using the `-f` flag, is constantly following the log stream and printing the newest messages! Hit `Ctrl`+`C` to cancel `tail` when you are done.

## 3. Setting up additional ports for log inguestion

 1. Editing the `logstash.conf` and adding the new port to the `input` section - e.g.:  
    ```json
        syslog {
            host => "0.0.0.0"
            port => 5141
            type => "syslog_combined" 
        }
    ```

 2. Reloading the services  
    ```bash
    docker compose down && docker compose up -d
    ```

## 4. Setting up a integration

 1. Navigate to `Management` -> `Integrations` and install the integration you need.
 2. Follow the configuration assistens - I have selected here pfSense and configured it with the name `pfsense` to listen on UDP port `5141`
 3. Navigate to `Management` -> `Stack Management` -> `Ingest pipeline` and search for your integration (here `pfsense` in our example).
 4. Configure the `output` -> `elasticsearch` section in the `logstash.conf` to use this pipeline - e.g.:  
    ```json
        elasticsearch {
            ...
            pipeline => "logs-pfsense.log-1.22.0" 
        }
    ```

Furthermore I added the `Windows` integration and configured it to inguest Sysmon, Defender and Powershell logs.

### Settings for pfSense and Windows Integration

**pfSense UDP**

| Integration name | Syslog host | Syslog Port | New agent policy name |
|------------------|-------------|-------------|-----------------------|
| `pfsense`        | `0.0.0.0`   | `5141`      | `pfsense-policy`      |

**Windows**

Integration name: `windows-additional-logs`

Activate:

 - AppLocker/EXE and DLL
 - AppLocker/MSI and Script
 - Packaged app-Deployment
 - Packaged app-Execution
 - Forwarded
 - Powershell
 - Powershell Operational
 - Sysmon operational
 - Windows Defender

Policy name: `windows-additional-logs-policy`

## 5. Setting up an Agent 

```powershell

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.7.1-windows-x86_64.zip -OutFile elastic-agent-8.7.1-windows-x86_64.zip
Expand-Archive .\elastic-agent-8.7.1-windows-x86_64.zip -DestinationPath .
cd elastic-agent-8.7.1-windows-x86_64
.\elastic-agent.exe install
```