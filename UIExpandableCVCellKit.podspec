Pod::Spec.new do |s|
  s.name             = 'UIExpandableCVCellKit'
  s.version          = '0.1.01'
  s.swift_versions   = '5.0'
  s.summary          = 'Recreate the Apple Appstore cell expansion experience!'

  s.description      = <<-DESC
Recreate the Apple Appstore cell experience when you tap on a cell.  Have the cell open up and maximize to full screen!
                       DESC

  s.homepage         = 'https://github.com/yungdai/UIExpandableCVCellKit/'
  s.license          = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }
  s.author           = { 'Yung Dai' => 'yungchidai@gmail.com' }
  s.source           = { :git => 'https://github.com/yungdai/UIExpandableCVCellKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.2'
  s.source_files = 'UIExpandableCVCellKit/*.{swift,h,m}'

end
