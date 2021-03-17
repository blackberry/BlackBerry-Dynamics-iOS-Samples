#
# Copyright (c) 2021 BlackBerry Limited. All Rights Reserved.
# Some modifications to the original from https://github.com/acmacalister/jetfire
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Pod::Spec.new do |s|
  s.name         = 'BbdJetfire'
  s.version      = '1.0.0'
  s.summary      = 'BlackBerry Dynamics WebSocket (RFC 6455) client library for iOS.'
  s.homepage     = 'https://developers.blackberry.com'
  s.license      = 'Apache License, Version 2.0'
  s.author       = { 'Volodymyr Taliar' => 'vtaliar@blackberry.com' }
  s.source       = { :git => "https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples.git" }
  s.ios.deployment_target = '9.0'
  s.source_files = 'WebSocket/*.{h,m}'
  s.requires_arc = true
  s.dependency "BlackBerryDynamics"
end
