local Influc = import 'components/influx/influx.libsonnet';

local baseConfig = {
};

{
  arre: Influc(baseConfig),
}
