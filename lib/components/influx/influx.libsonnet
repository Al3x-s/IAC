local k = import 'kausal.libsonnet';
local namespacelib = k.core.v1.namespace;
local statefulSet = k.apps.v1.statefulSet;
local container = k.core.v1.container;
local service = k.core.v1.service;
local default = {};

function(config={}) {
  local c = default + config,
  ns: {
    namespace: namespacelib.new(name='influx',)
  },
  sset:{
    influx: statefulSet.new(
        name='influxdb',
        replicas=1,
        containers=container.new(
            name="influxdb",
            image="influxdb:2.3.0-alpine"
        ) + container.withPorts({containerPort: 8086} + {name: 'influxdb'}) +
        container.withVolumeMounts({mountPath: '/var/lib/influxdb2'} + {name: 'data'}) 
    ) 
    + statefulSet.spec.selector.withMatchLabels({app: 'influxdb'})
    + statefulSet.spec.template.metadata.withLabels({app:'influxdb'})
    + statefulSet.spec.withServiceName('influxdb')
    + statefulSet.spec.withVolumeClaimTemplates(
        [
            {
                metadata: {
                    name: 'data',
                    namespace: 'influxdb'
                }
            } + 
            {
                spec: {
                    accessModes: ['ReadWriteOnce'],
                    resources: {
                        requests: {
                            storage: '5G'
                        }
                    }
                }
            }
        ]
    )
  },
  serv: {
    inlfluxService: service.new(name="influxdb",
    selector={app: 'influxdb'},
    ports={
        name:'inflxdb',
        port:8086,
        targetPort:8086
    }
    ) + service.spec.withType('ClusterIP')
  }
}

