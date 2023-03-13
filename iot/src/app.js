import * as mqtt from 'mqtt';
import * as Influx from 'influx';

// Set up the MQTT client
const mqttClient = mqtt.connect('mqtt://192.168.1.101');

// Set up the InfluxDB client
const influxClient = new Influx.InfluxDB({
  host: 'localhost',
  database: 'mydb',
});

// Subscribe to the MQTT topic
mqttClient.on('connect', () => {
  mqttClient.subscribe('my/topic');
});

// Handle incoming MQTT messages
mqttClient.on('message', (topic, message) => {
  // Convert the message buffer to a string
  const messageString = message.toString();

  // Save the message to the InfluxDB database
  influxClient.writePoints([
    {
      measurement: 'mqtt_messages',
      tags: {
        topic,
      },
      fields: {
        message: messageString,
      },
    },
  ]);
});