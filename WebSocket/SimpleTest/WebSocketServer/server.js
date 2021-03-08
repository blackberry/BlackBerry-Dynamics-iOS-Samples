/**
 * Copyright (c) 2020 BlackBerry Limited. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
const WebSocket = require('ws'),
      url = require('url');

const webSocketServer = new WebSocket.Server({
  port: 8080
});

webSocketServer.on('connection', (webSocket, req) => {
  console.log('/// New connection ///');
  const urlQuery = url.parse(req.url, true).query;

  webSocket.on('message', message => {
    console.log('Message:', message);
    webSocketServer.clients.forEach(client => {
      if (client.readyState === 1) {
        const now = new Date(),
              username = urlQuery.username ? ` ${urlQuery.username}` : '';

        client.send(`${now.getHours()}:${now.getMinutes()}:${now.getSeconds()}${username}: ${message}`);
      }
    });
  });

  webSocket.on('close', () => {
    console.log('Connection was closed!');
  });

  webSocket.send('Connected to WebSockets Server');
});
