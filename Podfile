# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

flutter_application_path = '../flutter_counter'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

target 'iOSCounterApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  target 'iOSCounterAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'iOSCounterAppUITests' do
    # Pods for testing
  end

  # Pods for iOSCounterApp
  install_all_flutter_pods(flutter_application_path)

end

post_install do |installer|
    flutter_post_install(installer) if defined?(flutter_post_install)
end
