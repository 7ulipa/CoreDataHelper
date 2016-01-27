@version = "0.0.1"

Pod::Spec.new do |s|
s.name         = "CoreDataHelper"
s.version      = @version
s.summary      = "Lightweight and sexy Core Data Helpers"
s.homepage     = "https://github.com/7ulipa/CoreDataHelper"
s.license      = { :type => 'MIT', :file => 'LICENSE' }

s.author       = { "Tulipa" => "darwin.jxzang@gmail.com" }
s.source       = { :git => "https://github.com/7ulipa/CoreDataHelper.git" }

s.source_files = 'Classes/*.{h,m}'
s.framework  = 'CoreData'
s.requires_arc = true

s.ios.deployment_target = '4.0'
s.osx.deployment_target = '10.6'

end